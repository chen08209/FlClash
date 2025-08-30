import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/services/v2board/v2board_api_service.dart';
import 'package:fl_clash/state.dart';

/// V2Board 订阅管理器
/// 负责从 V2Board 后端获取 Clash 订阅链接，并自动导入到 FlClash 客户端
class V2BoardSubscriptionManager {
  static V2BoardSubscriptionManager? _instance;
  static V2BoardSubscriptionManager get instance => _instance ??= V2BoardSubscriptionManager._();
  
  V2BoardSubscriptionManager._();
  
  static const String _v2boardProfilePrefix = 'V2Board_';
  
  /// 从 V2Board 获取并导入订阅
  Future<bool> importSubscriptionFromV2Board() async {
    try {
      commonPrint.log('V2BoardSubscriptionManager: Starting subscription import');
      
      // 获取 Clash 订阅链接
      final subscriptionUrl = await V2BoardApiService.instance.getClashSubscriptionUrl();
      commonPrint.log('V2BoardSubscriptionManager: Got subscription URL: $subscriptionUrl');
      
      // 清除旧的 V2Board 订阅
      await _removeOldV2BoardProfiles();
      
      // 导入新的订阅
      final success = await _importProfile(subscriptionUrl);
      
      if (success) {
        commonPrint.log('V2BoardSubscriptionManager: Subscription imported successfully');
        return true;
      } else {
        commonPrint.log('V2BoardSubscriptionManager: Failed to import subscription');
        return false;
      }
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error importing subscription: $e');
      return false;
    }
  }
  
  /// 更新现有的 V2Board 订阅
  Future<bool> updateV2BoardSubscription() async {
    try {
      commonPrint.log('V2BoardSubscriptionManager: Updating V2Board subscription');
      
      // 查找现有的 V2Board 配置文件
      final v2boardProfiles = await _findV2BoardProfiles();
      
      if (v2boardProfiles.isEmpty) {
        // 如果没有现有配置，直接导入新的
        return await importSubscriptionFromV2Board();
      }
      
      // 获取新的订阅链接
      final subscriptionUrl = await V2BoardApiService.instance.getClashSubscriptionUrl();
      
      // 更新每个 V2Board 配置文件
      bool allSuccess = true;
      for (final profile in v2boardProfiles) {
        final success = await _updateProfile(profile, subscriptionUrl);
        if (!success) {
          allSuccess = false;
        }
      }
      
      return allSuccess;
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error updating subscription: $e');
      return false;
    }
  }
  
  /// 重置 V2Board 订阅
  Future<bool> resetV2BoardSubscription() async {
    try {
      commonPrint.log('V2BoardSubscriptionManager: Resetting V2Board subscription');
      
      // 重置订阅链接
      final newSubscriptionUrl = await V2BoardApiService.instance.resetSubscriptionUrl();
      commonPrint.log('V2BoardSubscriptionManager: Got new subscription URL: $newSubscriptionUrl');
      
      // 清除旧的配置
      await _removeOldV2BoardProfiles();
      
      // 导入新的配置
      return await _importProfile(newSubscriptionUrl);
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error resetting subscription: $e');
      return false;
    }
  }
  
  /// 导入配置文件
  Future<bool> _importProfile(String subscriptionUrl) async {
    try {
      // 创建配置文件名
      final profileName = '$_v2boardProfilePrefix${DateTime.now().millisecondsSinceEpoch}';
      
      // 下载配置内容
      final configContent = await _downloadConfig(subscriptionUrl);
      if (configContent == null) {
        return false;
      }
      
      // 创建配置文件对象
      final profile = Profile(
        id: profileName,
        label: 'V2Board Subscription',
        url: subscriptionUrl,
        autoUpdateDuration: const Duration(hours: 24),
      );
      
      // 保存配置文件
      await _saveProfile(profile, configContent);
      
      // 设置为当前活动配置
      await _setActiveProfile(profile);
      
      return true;
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error importing profile: $e');
      return false;
    }
  }
  
  /// 更新配置文件
  Future<bool> _updateProfile(Profile profile, String newUrl) async {
    try {
      // 下载新的配置内容
      final configContent = await _downloadConfig(newUrl);
      if (configContent == null) {
        return false;
      }
      
      // 更新配置文件信息
      final updatedProfile = profile.copyWith(
        url: newUrl,
      );
      
      // 保存更新后的配置
      await _saveProfile(updatedProfile, configContent);
      
      return true;
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error updating profile: $e');
      return false;
    }
  }
  
  /// 下载配置内容
  Future<String?> _downloadConfig(String url) async {
    try {
      final response = await request.getTextResponseForUrl(url);
      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        commonPrint.log('V2BoardSubscriptionManager: Failed to download config, status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error downloading config: $e');
      return null;
    }
  }
  
  /// 保存配置文件
  Future<void> _saveProfile(Profile profile, String configContent) async {
    try {
      // 获取配置文件路径
      final profilePath = await appPath.getProfilePath(profile.id);
      final file = File(profilePath);

      // 确保目录存在
      await file.parent.create(recursive: true);

      // 保存配置内容到文件
      await file.writeAsString(configContent);

      // 更新全局状态中的配置列表
      final currentProfiles = globalState.config.profiles;
      final updatedProfiles = [...currentProfiles];

      // 查找是否已存在相同 ID 的配置
      final existingIndex = updatedProfiles.indexWhere((p) => p.id == profile.id);
      if (existingIndex != -1) {
        updatedProfiles[existingIndex] = profile;
      } else {
        updatedProfiles.add(profile);
      }

      // 更新全局配置
      globalState.config = globalState.config.copyWith(profiles: updatedProfiles);

      commonPrint.log('V2BoardSubscriptionManager: Profile saved: ${profile.id}');
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error saving profile: $e');
      rethrow;
    }
  }
  
  /// 设置活动配置文件
  Future<void> _setActiveProfile(Profile profile) async {
    try {
      // 更新当前配置文件 ID
      globalState.config = globalState.config.copyWith(currentProfileId: profile.id);
      
      // 通知应用控制器更新配置
      globalState.appController.handleChangeProfile();
      
      commonPrint.log('V2BoardSubscriptionManager: Set active profile: ${profile.id}');
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error setting active profile: $e');
    }
  }
  
  /// 查找现有的 V2Board 配置文件
  Future<List<Profile>> _findV2BoardProfiles() async {
    try {
      final allProfiles = globalState.config.profiles;
      return allProfiles.where((profile) =>
        profile.id.startsWith(_v2boardProfilePrefix) ||
        (profile.label?.contains('V2Board') ?? false)
      ).toList();
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error finding V2Board profiles: $e');
      return [];
    }
  }
  
  /// 移除旧的 V2Board 配置文件
  Future<void> _removeOldV2BoardProfiles() async {
    try {
      final v2boardProfiles = await _findV2BoardProfiles();
      
      for (final profile in v2boardProfiles) {
        await _removeProfile(profile);
      }
      
      commonPrint.log('V2BoardSubscriptionManager: Removed ${v2boardProfiles.length} old V2Board profiles');
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error removing old profiles: $e');
    }
  }
  
  /// 移除配置文件
  Future<void> _removeProfile(Profile profile) async {
    try {
      // 删除配置文件
      final profilePath = await appPath.getProfilePath(profile.id);
      final file = File(profilePath);
      if (await file.exists()) {
        await file.delete();
      }

      // 从全局配置中移除
      final currentProfiles = globalState.config.profiles;
      final updatedProfiles = currentProfiles.where((p) => p.id != profile.id).toList();
      globalState.config = globalState.config.copyWith(profiles: updatedProfiles);

      commonPrint.log('V2BoardSubscriptionManager: Removed profile: ${profile.id}');
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error removing profile: $e');
    }
  }
  
  /// 检查是否有 V2Board 订阅
  Future<bool> hasV2BoardSubscription() async {
    final v2boardProfiles = await _findV2BoardProfiles();
    return v2boardProfiles.isNotEmpty;
  }
  
  /// 获取 V2Board 订阅状态
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final v2boardProfiles = await _findV2BoardProfiles();
      final hasSubscription = v2boardProfiles.isNotEmpty;
      
      Profile? activeProfile;
      if (hasSubscription) {
        final currentProfileId = globalState.config.currentProfileId;
        activeProfile = v2boardProfiles.firstWhere(
          (p) => p.id == currentProfileId,
          orElse: () => v2boardProfiles.first,
        );
      }
      
      return {
        'hasSubscription': hasSubscription,
        'profileCount': v2boardProfiles.length,
        'activeProfile': activeProfile?.toJson(),
        'lastUpdate': activeProfile?.lastUpdateDate?.toIso8601String(),
      };
    } catch (e) {
      commonPrint.log('V2BoardSubscriptionManager: Error getting subscription status: $e');
      return {
        'hasSubscription': false,
        'profileCount': 0,
        'error': e.toString(),
      };
    }
  }
}
