import Foundation
import ObjectiveC

// flutter/flutter#185394, see "Wrong-size back buffer on macOS" in .agents/flutter-upgrade.md.
enum BackBufferCacheGuard {
    private static var installed = false

    static func install() {
        let selector = NSSelectorFromString("removeSurfaceForSize:")
        guard !installed,
              let cacheClass = NSClassFromString("FlutterBackBufferCache"),
              let method = class_getInstanceMethod(cacheClass, selector)
        else { return }
        installed = true
        typealias RemoveSurface = @convention(c) (AnyObject, Selector, CGSize) -> Unmanaged<AnyObject>?
        let original = unsafeBitCast(method_getImplementation(method), to: RemoveSurface.self)
        let guarded: @convention(block) (AnyObject, CGSize) -> AnyObject? = { cache, size in
            guard let surface = original(cache, selector, size)?.takeUnretainedValue() else { return nil }
            return (surface.value(forKey: "size") as? NSValue)?.sizeValue == size ? surface : nil
        }
        method_setImplementation(method, imp_implementationWithBlock(guarded))
    }
}
