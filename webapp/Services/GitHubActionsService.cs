using Octokit;

namespace CopilotWebApp.Services;

/// <summary>
/// GitHub Actions の workflow_dispatch トリガー、ステータス確認、Artifacts 取得を行うサービス。
/// </summary>
public class GitHubActionsService
{
    private readonly GitHubClient _client;
    private readonly string _owner;
    private readonly string _repo;
    private readonly string _workflowFileName;
    private readonly ILogger<GitHubActionsService> _logger;

    public GitHubActionsService(IConfiguration config, ILogger<GitHubActionsService> logger)
    {
        _logger = logger;
        _owner = config["GitHub:Owner"] ?? throw new ArgumentException("GitHub:Owner is required");
        _repo = config["GitHub:Repo"] ?? throw new ArgumentException("GitHub:Repo is required");
        _workflowFileName = config["GitHub:WorkflowFileName"] ?? "copilot-poc.yml";

        var token = config["GitHub:Token"] ?? throw new ArgumentException("GitHub:Token is required");
        _client = new GitHubClient(new ProductHeaderValue("CopilotWebApp"))
        {
            Credentials = new Credentials(token)
        };
    }

    /// <summary>
    /// ワークフローを手動トリガーする。
    /// </summary>
    public async Task<bool> TriggerWorkflowAsync(string prompt, string model = "claude-opus-4.6", string branch = "master")
    {
        try
        {
            var inputs = new Dictionary<string, object>
            {
                ["prompt"] = prompt,
                ["model"] = model,
                ["source"] = "webapp"
            };

            // Octokit の CreateDispatch を使用
            await _client.Actions.Workflows.CreateDispatch(
                _owner, _repo, _workflowFileName,
                new CreateWorkflowDispatch(branch) { Inputs = inputs });

            _logger.LogInformation("Workflow triggered: prompt={Prompt}, model={Model}", prompt, model);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to trigger workflow");
            return false;
        }
    }

    /// <summary>
    /// 最新のワークフロー実行一覧を取得する。
    /// </summary>
    public async Task<IReadOnlyList<WorkflowRun>> GetRecentRunsAsync(int count = 20)
    {
        try
        {
            var runs = await _client.Actions.Workflows.Runs.ListByWorkflow(
                _owner, _repo, _workflowFileName,
                new WorkflowRunsRequest(),
                new ApiOptions { PageSize = count, PageCount = 1 });

            return runs.WorkflowRuns;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get workflow runs");
            return Array.Empty<WorkflowRun>();
        }
    }

    /// <summary>
    /// 実行中・待機中のワークフロー実行を取得する（プロンプト付き）。
    /// </summary>
    public async Task<List<InProgressRunInfo>> GetInProgressRunsAsync()
    {
        var result = new List<InProgressRunInfo>();
        try
        {
            // 未完了ステータスをサーバー側でフィルタして取得（より確実）
            var statusFilters = new CheckRunStatusFilter[]
            {
                CheckRunStatusFilter.InProgress,
                CheckRunStatusFilter.Queued
            };

            foreach (var statusFilter in statusFilters)
            {
                try
                {
                    var request = new WorkflowRunsRequest { Status = statusFilter };
                    var response = await _client.Actions.Workflows.Runs.ListByWorkflow(
                        _owner, _repo, _workflowFileName, request,
                        new ApiOptions { PageSize = 10, PageCount = 1 });

                    foreach (var run in response.WorkflowRuns)
                    {
                        var status = run.Status.StringValue;
                        _logger.LogInformation(
                            "In-progress run found: #{RunId} status={Status} title={Title}",
                            run.Id, status, run.DisplayTitle);

                        result.Add(new InProgressRunInfo
                        {
                            RunNumber = (int)run.RunNumber,
                            RunId = run.Id,
                            Status = status,
                            Prompt = run.DisplayTitle ?? run.Name ?? "",
                            CreatedAt = run.CreatedAt,
                            HtmlUrl = run.HtmlUrl
                        });
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to fetch runs with status filter");
                }
            }

            // 重複を除去
            result = result.DistinctBy(r => r.RunId).OrderByDescending(r => r.CreatedAt).ToList();
            _logger.LogInformation("GetInProgressRunsAsync: found {Count} in-progress/queued runs", result.Count);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get in-progress runs");
        }
        return result;
    }

    /// <summary>
    /// 特定の実行の詳細を取得する。
    /// </summary>
    public async Task<WorkflowRun?> GetRunAsync(long runId)
    {
        try
        {
            return await _client.Actions.Workflows.Runs.Get(_owner, _repo, runId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get run {RunId}", runId);
            return null;
        }
    }

    /// <summary>
    /// 実行の Artifacts 一覧を取得する。
    /// </summary>
    public async Task<IReadOnlyList<Artifact>> GetArtifactsAsync(long runId)
    {
        try
        {
            var artifacts = await _client.Actions.Artifacts.ListWorkflowArtifacts(
                _owner, _repo, runId);
            return artifacts.Artifacts;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get artifacts for run {RunId}", runId);
            return Array.Empty<Artifact>();
        }
    }

    /// <summary>
    /// Artifact の ZIP をダウンロードする。
    /// </summary>
    public async Task<byte[]?> DownloadArtifactAsync(long artifactId)
    {
        try
        {
            using var stream = await _client.Actions.Artifacts.DownloadArtifact(
                _owner, _repo, artifactId, "zip");
            using var ms = new MemoryStream();
            await stream.CopyToAsync(ms);
            return ms.ToArray();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to download artifact {ArtifactId}", artifactId);
            return null;
        }
    }
}

/// <summary>
/// 実行中・待機中のワークフロー情報。
/// </summary>
public class InProgressRunInfo
{
    public int RunNumber { get; set; }
    public long RunId { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Prompt { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }
    public string HtmlUrl { get; set; } = string.Empty;
}
