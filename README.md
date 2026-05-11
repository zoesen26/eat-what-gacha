# 吃什么扭蛋小程序

一个单文件网页小程序，用扭蛋机随机决定今天吃什么。

## 本地预览

```powershell
python -m http.server 8787 --bind 0.0.0.0
```

打开：

- 本机：`http://127.0.0.1:8787/index.html`
- 局域网手机：使用电脑当前局域网 IP，例如 `http://172.23.207.162:8787/index.html`

## GitHub Pages 部署

1. 在 GitHub 新建仓库。
2. 把本仓库推送到 GitHub。
3. 进入仓库 `Settings` -> `Pages`。
4. `Build and deployment` 选择 `Deploy from a branch`。
5. `Branch` 选择 `main`，目录选择 `/root`，保存。

部署完成后，访问 GitHub Pages 给出的地址即可。
