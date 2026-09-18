$csSource = @"
using System;
using System.IO;
using System.Net;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;

public class FastMediaServer {
    private HttpListener _listener;
    private string _root;
    private int _port;
    private bool _running;
    private static readonly Dictionary<string, string> MimeTypes = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase) {
        { ".html", "text/html; charset=utf-8" },
        { ".htm", "text/html; charset=utf-8" },
        { ".css", "text/css; charset=utf-8" },
        { ".js", "application/javascript; charset=utf-8" },
        { ".json", "application/json; charset=utf-8" },
        { ".jpg", "image/jpeg" },
        { ".jpeg", "image/jpeg" },
        { ".png", "image/png" },
        { ".webp", "image/webp" },
        { ".gif", "image/gif" },
        { ".svg", "image/svg+xml" },
        { ".ico", "image/x-icon" },
        { ".mp4", "video/mp4" },
        { ".webm", "video/webm" },
        { ".ogg", "video/ogg" }
    };

    public FastMediaServer(string root, int port) {
        _root = Path.GetFullPath(root);
        _port = port;
    }

    public void Start() {
        _listener = new HttpListener();
        _listener.Prefixes.Add("http://localhost:" + _port + "/");
        _listener.Prefixes.Add("http://127.0.0.1:" + _port + "/");
        try {
            _listener.Start();
        } catch {
            _port = 8085;
            _listener = new HttpListener();
            _listener.Prefixes.Add("http://localhost:" + _port + "/");
            _listener.Prefixes.Add("http://127.0.0.1:" + _port + "/");
            _listener.Start();
        }
        _running = true;
        Console.WriteLine("FastMediaServer running at http://localhost:" + _port + "/");
        Console.WriteLine("Serving files from " + _root);

        Task.Run(async () => {
            while (_running && _listener.IsListening) {
                try {
                    var context = await _listener.GetContextAsync();
                    ThreadPool.QueueUserWorkItem(s => ProcessRequest((HttpListenerContext)s), context);
                } catch {
                    if (!_running) break;
                }
            }
        });
    }

    private void ProcessRequest(HttpListenerContext context) {
        var req = context.Request;
        var res = context.Response;
        try {
            string raw = req.Url.AbsolutePath;
            if (string.IsNullOrEmpty(raw) || raw == "/") raw = "/index.html";
            string relative = raw.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
            string filePath = Path.Combine(_root, Uri.UnescapeDataString(relative));

            if (!File.Exists(filePath)) {
                res.StatusCode = 404;
                byte[] notFound = System.Text.Encoding.UTF8.GetBytes("404 Not Found");
                res.ContentType = "text/plain";
                res.ContentLength64 = notFound.Length;
                res.OutputStream.Write(notFound, 0, notFound.Length);
                res.Close();
                return;
            }

            string ext = Path.GetExtension(filePath);
            string mime;
            if (!MimeTypes.TryGetValue(ext, out mime)) mime = "application/octet-stream";

            res.ContentType = mime;
            res.AddHeader("Access-Control-Allow-Origin", "*");
            res.AddHeader("Accept-Ranges", "bytes");
            res.AddHeader("Cache-Control", "public, max-age=3600");

            var fileInfo = new FileInfo(filePath);
            long totalLen = fileInfo.Length;
            string rangeHeader = req.Headers["Range"];

            if (!string.IsNullOrEmpty(rangeHeader) && rangeHeader.StartsWith("bytes=")) {
                string rangeStr = rangeHeader.Substring(6).Trim();
                string[] parts = rangeStr.Split('-');
                long start = 0;
                long end = totalLen - 1;

                if (!string.IsNullOrEmpty(parts[0])) {
                    long.TryParse(parts[0], out start);
                }
                if (parts.Length > 1 && !string.IsNullOrEmpty(parts[1])) {
                    long.TryParse(parts[1], out end);
                }
                if (end >= totalLen) end = totalLen - 1;
                if (start > end) start = 0;
                long contentLength = end - start + 1;

                res.StatusCode = 206;
                res.AddHeader("Content-Range", string.Format("bytes {0}-{1}/{2}", start, end, totalLen));
                res.ContentLength64 = contentLength;

                if (!string.Equals(req.HttpMethod, "HEAD", StringComparison.OrdinalIgnoreCase)) {
                    using (var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
                        fs.Seek(start, SeekOrigin.Begin);
                        byte[] buffer = new byte[64 * 1024];
                        long remaining = contentLength;
                        while (remaining > 0) {
                            int toRead = (int)Math.Min((long)buffer.Length, remaining);
                            int read = fs.Read(buffer, 0, toRead);
                            if (read <= 0) break;
                            res.OutputStream.Write(buffer, 0, read);
                            remaining -= read;
                        }
                    }
                }
            } else {
                res.StatusCode = 200;
                res.ContentLength64 = totalLen;
                if (!string.Equals(req.HttpMethod, "HEAD", StringComparison.OrdinalIgnoreCase)) {
                    using (var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
                        fs.CopyTo(res.OutputStream);
                    }
                }
            }
        } catch {
            // Client aborted or closed stream - normal for video seeking
        } finally {
            try { res.Close(); } catch {}
        }
    }

    public void Stop() {
        _running = false;
        try { if (_listener != null) _listener.Stop(); } catch {}
    }
}
"@

Add-Type -TypeDefinition $csSource
Write-Output "FastMediaServer compiled successfully!"
