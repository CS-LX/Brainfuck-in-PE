# BfdllCSharp — C# 验收宿主

用 P/Invoke 调用 `bfdll.dll`，验收项与 `host/test_host.c` 对齐。

## 前置条件

1. 已用 MSVC x64 构建 BFDll：

```powershell
cmake -S ../.. -B ../../build -G "Visual Studio 17 2022" -A x64
cmake --build ../../build --config Release
```

2. 已安装 .NET 8 SDK。

## 运行

```powershell
cd examples/BfdllCSharp
dotnet run -c Release
```

成功时输出 `All C# acceptance tests passed.` 且退出码为 0。

## 说明

- 项目固定 **x64**（`PlatformTarget` + `win-x64`），与 `bfdll.dll` 架构一致。
- 若存在 `build/bin/Release/bfdll.dll`，构建时会自动复制到输出目录。
- 若 DLL 未构建，需手动将 `bfdll.dll` 放到 `bin/Release/net8.0/win-x64/` 旁。
