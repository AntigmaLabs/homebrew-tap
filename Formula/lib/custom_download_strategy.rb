require "download_strategy"

# GitHubPrivateRepositoryReleaseDownloadStrategy downloads tarballs from GitHub
# Release assets. To use it, add `:using => GitHubPrivateRepositoryReleaseDownloadStrategy` 
# to the URL section of your formula. This download strategy uses GitHub access tokens 
# (in the environment variable HOMEBREW_GITHUB_API_TOKEN) to sign the request.
class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  require "utils/formatter"
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
  end

  def parse_url_pattern
    url_pattern = %r{https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Release."
    end

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    set_github_token
    
    # HTTP request header `Accept: application/octet-stream` is required.
    # Without this, the GitHub API will respond with metadata, not binary.
    curl_download download_url, 
                  "--header", "Accept: application/octet-stream",
                  "--header", "Authorization: token #{@github_token}",
                  to: temporary_path
  rescue => e
    ohai "Failed to download using GitHub API, falling back to alternative methods"
    fallback_download
  end

  def fallback_download
    # Try using system_command with curl directly
    system_command!("curl",
      args: [
        "--fail",
        "--location",
        "--silent",
        "--retry", "3",
        "--output", temporary_path.to_s,
        "--header", "Accept: application/octet-stream",
        "--header", "Authorization: token #{@github_token}",
        download_url
      ],
      print_stdout: false
    )
  end

  def set_github_token
    @github_token = find_github_token
    
    unless @github_token
      raise CurlDownloadStrategyError, <<~EOS
        HOMEBREW_GITHUB_API_TOKEN is required for private repository access.
        
        Please use one of these methods:
        
        1. GitHub CLI (recommended):
           brew install gh
           gh auth login
           export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)
           
        2. Personal Access Token:
           Create at: https://github.com/settings/tokens/new
           Scopes needed: repo (for private repos)
           export HOMEBREW_GITHUB_API_TOKEN=ghp_your_token_here
           
        3. Add to shell profile (~/.zshrc or ~/.bashrc):
           if command -v gh &> /dev/null && gh auth status &> /dev/null 2>&1; then
               export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)
           fi
      EOS
    end

    validate_github_repository_access!
  end

  def find_github_token
    # Try multiple sources for the token
    token = ENV["HOMEBREW_GITHUB_API_TOKEN"] || 
            ENV["GITHUB_TOKEN"] ||
            ENV["GH_TOKEN"]
    
    # Try GitHub CLI if no environment variable is set
    if token.nil? || token.empty?
      token = github_cli_token
    end
    
    token
  end

  def github_cli_token
    return nil unless which("gh")
    
    token = Utils.safe_popen_read("gh", "auth", "token").strip
    token.empty? ? nil : token
  rescue
    nil
  end

  def validate_github_repository_access!
    # Test access to the repository
    GitHub::API.repository(@owner, @repo)
  rescue GitHub::HTTPNotFoundError
    # We only handle HTTPNotFoundError here,
    # because AuthenticationFailedError is handled within util/github.
    message = <<~EOS
      HOMEBREW_GITHUB_API_TOKEN cannot access the repository: #{@owner}/#{@repo}
      
      This token may not have permission to access the repository or the url 
      of the formula may be incorrect.
      
      Try running: gh auth refresh --scopes repo
    EOS
    raise CurlDownloadStrategyError, message
  rescue GitHub::API::AuthenticationFailedError => e
    message = <<~EOS
      Authentication failed: #{e.message}
      
      Your token may be invalid or expired. Try:
      1. gh auth refresh
      2. Create a new token at https://github.com/settings/tokens
    EOS
    raise CurlDownloadStrategyError, message
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release_metadata = fetch_release_metadata
    
    unless release_metadata && release_metadata["assets"]
      raise CurlDownloadStrategyError, "Unable to fetch release metadata for #{@tag}"
    end
    
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    
    if assets.empty?
      available_assets = release_metadata["assets"].map { |a| a["name"] }.join(", ")
      raise CurlDownloadStrategyError, <<~EOS
        Asset file '#{@filename}' not found in release #{@tag}.
        
        Available assets: #{available_assets}
      EOS
    end
    
    assets.first["id"]
  end

  def fetch_release_metadata
    release_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}"
    GitHub::API.open_rest(release_url)
  rescue GitHub::API::Error => e
    ohai "Failed to fetch release metadata: #{e.message}"
    # Try alternative API endpoint
    releases_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases"
    releases = GitHub::API.open_rest(releases_url)
    releases.find { |r| r["tag_name"] == @tag }
  end
end

# Alias for compatibility with different naming conventions
GitHubPrivateReleaseDownloadStrategy = GitHubPrivateRepositoryReleaseDownloadStrategy

# Enhanced strategy with better error handling and multiple fallback methods
class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  require "utils/formatter"
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
  end

  def parse_url_pattern
    unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/(\S+)})
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Repository."
    end

    _, @owner, @repo, @filepath = *match
  end

  def download_url
    "https://#{@github_token}@github.com/#{@owner}/#{@repo}/#{@filepath}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    set_github_token
    curl_download download_url, to: temporary_path
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, <<~EOS
        Environmental variable HOMEBREW_GITHUB_API_TOKEN is required.
        
        Set it with: export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)
      EOS
    end

    validate_github_repository_access!
  end

  def validate_github_repository_access!
    # Test access to the repository
    GitHub::API.repository(@owner, @repo)
  rescue GitHub::HTTPNotFoundError
    message = <<~EOS
      HOMEBREW_GITHUB_API_TOKEN cannot access the repository: #{@owner}/#{@repo}
      
      This token may not have permission to access the repository or the url 
      of the formula may be incorrect.
    EOS
    raise CurlDownloadStrategyError, message
  end
end