import Foundation

@available(iOS 13.0, *)
public class BuilderContentWrapper: ObservableObject {
  public var content: BuilderContent? = nil
  public init(content: BuilderContent? = nil) {
    self.content = content
  }

  public func changeContent(_ newValue: BuilderContent?) {
    self.content = newValue
    self.objectWillChange.send()
  }
}
