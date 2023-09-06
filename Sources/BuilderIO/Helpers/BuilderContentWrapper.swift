
import Foundation

@available(iOS 13.0, *)
class BuilderContentWrapper: ObservableObject {
    var content: BuilderContent? = nil;
    init(content: BuilderContent? = nil) {
        self.content = content
    }
    
    func changeContent(_ newValue: BuilderContent?) {
        self.content = newValue;
        self.objectWillChange.send();
    }
}
