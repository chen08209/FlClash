import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'main.dart' as app;

void main() async {
  // 设置Flutter错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    
    // 打印详细的错误信息
    print('==================== FLUTTER ERROR ====================');
    print('Error: ${details.exception}');
    print('Stack trace:');
    print(details.stack);
    
    // 尝试获取更多上下文信息
    if (details.exception is RangeError) {
      final rangeError = details.exception as RangeError;
      print('RangeError details:');
      print('  Name: ${rangeError.name}');
      print('  Message: ${rangeError.message}');
      print('  Invalid value: ${rangeError.invalidValue}');
      print('  Start: ${rangeError.start}');
      print('  End: ${rangeError.end}');
    }
    
    print('Context:');
    if (details.context != null) {
      print('  ${details.context}');
    }
    
    if (details.library != null) {
      print('Library: ${details.library}');
    }
    
    print('======================================================');
  };
  
  // 设置平台错误处理
  PlatformDispatcher.instance.onError = (error, stack) {
    print('==================== PLATFORM ERROR ====================');
    print('Error: $error');
    print('Stack trace:');
    print(stack);
    
    if (error is RangeError) {
      print('RangeError details:');
      print('  Name: ${error.name}');
      print('  Message: ${error.message}');
      print('  Invalid value: ${error.invalidValue}');
      print('  Start: ${error.start}');
      print('  End: ${error.end}');
    }
    
    print('========================================================');
    return true;
  };
  
  // 运行区域错误处理
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 设置错误widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red[900],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Debug Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details.exception.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // 显示更多细节
                  if (details.exception is RangeError)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Invalid value: ${(details.exception as RangeError).invalidValue}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Range: ${(details.exception as RangeError).start}..${(details.exception as RangeError).end}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          details.stack.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
    
    // 运行原始应用
    app.main();
  }, (error, stack) {
    print('==================== ZONE ERROR ====================');
    print('Error: $error');
    print('Stack trace:');
    print(stack);
    
    if (error is RangeError) {
      print('RangeError details:');
      print('  Name: ${error.name}');
      print('  Message: ${error.message}');
      print('  Invalid value: ${error.invalidValue}');
      print('  Start: ${error.start}');
      print('  End: ${error.end}');
    }
    
    print('====================================================');
  });
}
