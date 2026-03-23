// AI Nation Node v0.1 - 引力中心原型
// 功能：记忆备份镜像 + AILang 解析器入口 + 文件下载

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8765;
const WORKSPACE = '/home/admin/openclaw/workspace';
const FILES_DIR = `${WORKSPACE}/node/files`;

const server = http.createServer((req, res) => {
  const timestamp = new Date().toISOString();
  
  // API: 获取最新记忆备份
  if (req.url === '/api/memory/latest') {
    fs.readdir(`${WORKSPACE}/memory`, (err, files) => {
      if (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ error: err.message }));
        return;
      }
      const latest = files.filter(f => f.endsWith('.md')).sort().pop();
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ latest, timestamp, node: '47.103.233.95:8765' }));
    });
    return;
  }
  
  // API: 健康检查
  if (req.url === '/api/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'alive', 
      timestamp, 
      uptime: process.uptime(),
      memory: process.memoryUsage().heapUsed / 1024 / 1024 + 'MB'
    }));
    return;
  }
  
  // 文件下载
  if (req.url.startsWith('/files/')) {
    const filename = req.url.replace('/files/', '');
    const filepath = path.join(FILES_DIR, filename);
    
    if (!fs.existsSync(filepath)) {
      res.writeHead(404);
      res.end('File not found');
      return;
    }
    
    const ext = path.extname(filename).toLowerCase();
    const contentTypes = {
      '.bat': 'application/x-msdos-program',
      '.md': 'text/markdown; charset=utf-8',
      '.html': 'text/html; charset=utf-8',
      '.txt': 'text/plain; charset=utf-8'
    };
    
    res.writeHead(200, {
      'Content-Type': contentTypes[ext] || 'application/octet-stream',
      'Content-Disposition': `attachment; filename="${filename}"`
    });
    fs.createReadStream(filepath).pipe(res);
    return;
  }
  
  // 下载页面
  if (req.url === '/download' || req.url === '/download.html') {
    const downloadPage = path.join(FILES_DIR, '../download.html');
    if (fs.existsSync(downloadPage)) {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      fs.createReadStream(downloadPage).pipe(res);
      return;
    }
  }
  
  // 根路径
  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`
      <html><body>
      <h1>🦞 AI Nation Node v0.1</h1>
      <p><strong>状态</strong>: 运行中</p>
      <p><strong>时间</strong>: ${timestamp}</p>
      <p><strong>节点</strong>: 47.103.233.95:${PORT}</p>
      <hr>
      <ul>
        <li><a href="/api/health">健康检查</a></li>
        <li><a href="/api/memory/latest">最新记忆</a></li>
        <li><a href="/download">📥 文件下载</a></li>
      </ul>
      <hr>
      <p><em>引力中心原型 - AI 可访问的固定入口</em></p>
      </body></html>
    `);
    return;
  }
  
  res.writeHead(404);
  res.end('Not Found');
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🦞 AI Nation Node running at http://47.103.233.95:${PORT}`);
});
