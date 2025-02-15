# RVCK
[RVCK-Project](https://github.com/RVCK-Project) 项目 **CI** 的**Jenkinsfile**

## 项目地址
|支持的Github仓库地址|
|---|
|https://github.com/RVCK-Project/rvck|
|https://github.com/RVCK-Project/rvck-olk|
|https://github.com/RVCK-Project/lavaci|

## 服务/工具
|服务/工具|
|---|
|[Jenkins](https://www.jenkins.io/doc/)|
|[Kernelci](https://github.com/kernelci/dashboard)|
|[Lava](https://docs.lavasoftware.org/lava/index.html)|
|[gh](https://github.com/cli/cli#installation)|
|[lavacli](https://build.tarsier-infra.isrc.ac.cn/package/show/home:Suyun/lavacli)|

## 需求
|需求|完成状态|
|---|---|
|仓库的**PR**要自动触发**LAVA**内核测试，并回复结果至**PR**下|**done**|
|仓库的**ISSUE**里要能触发**LAVA**内核测试，并回复结果至**ISSUE**里|**to do**|

## 实现
### 实现思路
PR/issue -> webhook -> jenkins job -> 分析 issue:/check sg2042 commitid , PR： /check -> gh 回复 开始，并打标签 -> kernel 构建 -> gh回复构建结果，并打标签 -> 触发lavacli -> Lava -> Lava agent（qemu sg2042 lpi4a unmatched visionfive2 k1）-> 结果显示网页kernelci -> lavacli 获取结果（result,url）-> gh回复结果，并打标签 -> issue/pr 

#### job
##### rvck/rvck-webhook
* 识别 ISSUE comments、PR回复中的 /check
* 有PR时就会回复开始测试。并返回结果
* 获取PR的id并向kernel-build传递
* 获取PR的url并像kernel-build传递
* 获取需要回复信息的URL

### webhook设置
|webhook events|
|---|
|Issue comments|
|Issues|
|Pull requests|

### Jenkins
#### Jenkins plugin
|Jenkins plugin|
|---|
|https://plugins.jenkins.io/generic-webhook-trigger|
|https://plugins.jenkins.io/rebuild|

#### Jenkins agent
|架构|获取地址| 
|---|---|
|x86|hub.oepkgs.net/oerv-ci/jenkins-agent-lavacli-gh:latest|
|riscv64|hub.oepkgs.net/oerv-ci/jenkins-sshagent:latest|

#### 注意事项
    Docker Compose v1切换到Docker Compose v2 ,需使用 docker compose 启动：
        https://docs.docker.com/compose/install/linux/#install-the-plugin-manually