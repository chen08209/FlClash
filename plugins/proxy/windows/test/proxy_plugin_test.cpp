#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>

#include <memory>
#include <string>
#include <variant>

#include "proxy_plugin.h"

namespace proxy {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

TEST(ProxyPlugin, UnknownMethodIsNotImplemented) {
  ProxyPlugin plugin;
  bool not_implemented = false;
  plugin.HandleMethodCall(
      MethodCall("unknown", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          nullptr, nullptr,
          [&not_implemented]() { not_implemented = true; }));

  EXPECT_TRUE(not_implemented);
}

TEST(ProxyPlugin, StartProxyRejectsMissingArguments) {
  ProxyPlugin plugin;
  std::string error_code;
  plugin.HandleMethodCall(
      MethodCall("StartProxy", std::make_unique<EncodableValue>(EncodableMap())),
      std::make_unique<MethodResultFunctions<>>(
          nullptr,
          [&error_code](
              const std::string& code,
              const std::string& message,
              const EncodableValue* details) { error_code = code; },
          nullptr));

  EXPECT_EQ(error_code, "bad_args");
}

TEST(ProxyPlugin, StartProxyRejectsInvalidPort) {
  ProxyPlugin plugin;
  std::string error_code;
  EncodableMap arguments = {
      {EncodableValue("port"), EncodableValue(70000)},
      {EncodableValue("bypassDomain"), EncodableValue(EncodableList())}};

  plugin.HandleMethodCall(
      MethodCall(
          "StartProxy",
          std::make_unique<EncodableValue>(std::move(arguments))),
      std::make_unique<MethodResultFunctions<>>(
          nullptr,
          [&error_code](
              const std::string& code,
              const std::string& message,
              const EncodableValue* details) { error_code = code; },
          nullptr));

  EXPECT_EQ(error_code, "bad_args");
}

TEST(ProxyPlugin, StartProxyRejectsNonStringBypassDomain) {
  ProxyPlugin plugin;
  std::string error_code;
  EncodableList bypass_domain = {
      EncodableValue("localhost"),
      EncodableValue(1)};
  EncodableMap arguments = {
      {EncodableValue("port"), EncodableValue(7890)},
      {EncodableValue("bypassDomain"),
       EncodableValue(std::move(bypass_domain))}};

  plugin.HandleMethodCall(
      MethodCall(
          "StartProxy",
          std::make_unique<EncodableValue>(std::move(arguments))),
      std::make_unique<MethodResultFunctions<>>(
          nullptr,
          [&error_code](
              const std::string& code,
              const std::string& message,
              const EncodableValue* details) { error_code = code; },
          nullptr));

  EXPECT_EQ(error_code, "bad_args");
}

}  // namespace test
}  // namespace proxy
