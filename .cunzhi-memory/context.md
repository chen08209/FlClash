# 项目上下文信息

- FlClash项目的免责声明弹窗已被禁用。在lib/controller.dart第573行注释掉了await _handlerDisclaimer();调用，使应用启动时不再显示免责声明弹窗。用户仍可通过设置页面手动查看免责声明内容。
- FlClash项目优化了启动时的API调用：解决了启动后多次调用/api/v1/user/getSubscribe接口的问题。修改了lib/controller.dart中的_autoUpdateServerSubscription()方法，在获取订阅信息后立即调用updateServerSubscription()。同时修改了lib/views/dashboard/modern_dashboard.dart，避免重复调用getSubscribe接口，改为调用getUserInfo获取用户信息。现在启动时只调用一次getSubscribe接口且会立即更新订阅。
