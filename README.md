# clover 固件编译（GitHub Actions）

把小米平板4（clover, SDM660）的 UEFI 启动镜像 `clover-boot.img` 放到 GitHub 云端编译。

## 这个仓库里有什么

```
.github/workflows/build.yml   编译工作流（你只需要点 Run workflow）
p-xbl.bin                     从你的平板提取的 XBL 固件（厂商 blob 来源）
clover.dtb                    从你的原厂 boot 镜像拆出的设备树
```

## 你要做的 4 步

### 第 1 步：新建仓库

1. 打开 https://github.com ，登录
2. 点右上角 **+** → **New repository**
3. Repository name 填 `clover-build`（随便填也行）
4. 选 **Public**（免费额度才够，私有仓库也能跑但要留意额度）
5. **不要**勾选 "Add a README"
6. 点 **Create repository**

### 第 2 步：上传这 4 个文件

新仓库创建后，会显示一个「Quick setup」页面。点 **uploading an existing file** 链接（蓝色文字）。

然后**把下面这 4 个东西全部拖进去**：

- `.github/workflows/build.yml`
- `p-xbl.bin`
- `clover.dtb`

注意：`.github/workflows/build.yml` 这个文件，在 Windows 资源管理器里打开 `gh-actions` 文件夹，直接**把整个 `.github` 文件夹和两个 .bin/.dtb 文件一起拖进网页**即可。拖完后：

1. 下面 Commit message 随便填（比如 `add build workflow`）
2. 点 **Commit changes**

### 第 3 步：运行工作流

1. 仓库顶部点 **Actions** 标签
2. 左侧列表点 **build-clover-bootimg**
3. 右侧点 **Run workflow** 按钮（灰色下拉 → 点绿色的 Run workflow）
4. 等它跑（首次约 20-40 分钟，会显示黄色转圈）

### 第 4 步：下载产物

1. 跑完后，绿色对勾出现
2. 点进这次运行，页面底部 **Artifacts** 区域
3. 点 **clover-boot-img** 下载（一个 zip，里面有 `clover-boot.img`）

## 刷机（下载后，回到有平板的电脑）

```bash
fastboot flash boot  clover-boot.img
fastboot flash cache round149-payload.img
fastboot reboot
```

回滚（原厂 boot 备份）：

```bash
fastboot flash boot stock-boot.img && fastboot reboot
```

## 如果编译失败

点进失败的那一步，展开看红字报错，把最后 20 行贴给 WorkBuddy。
最常见的失败是 `fetch-mu-silicium` 拉取超时——重跑一次通常就好。
