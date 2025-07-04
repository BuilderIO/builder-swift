import SwiftUI

//BuilderComponentRegistry single instance factory for building preregistered components
public class BuilderComponentRegistry {
  public static let shared = BuilderComponentRegistry()

  //Component Registry
  private var registry: [BuilderComponentType: any BuilderViewProtocol.Type] = [:]

  // Returns the view for a given block by looking up the component type in the registry.
  // Wrapped in anyview as Swift UI does not support dynamic type instantiation directly
  func view(for block: BuilderBlockModel) -> AnyView {
    let type = BuilderComponentType(rawValue: block.component?.name ?? "")

    guard let viewType = registry[type] else {
      // If the type is not registered, return an empty view
      return AnyView(BuilderEmptyView(block: block))
    }

    let view = viewType.init(block: block)
    return AnyView(view)
  }

  //Register default components
  func initialize() {
    register(type: BuilderText.componentType, viewClass: BuilderText.self)
    register(type: BuilderImage.componentType, viewClass: BuilderImage.self)
    register(type: BuilderButton.componentType, viewClass: BuilderButton.self)
    register(type: BuilderColumns.componentType, viewClass: BuilderColumns.self)
    register(type: BuilderSection.componentType, viewClass: BuilderSection.self)
  }

  //Register Custom component
  func register(type: BuilderComponentType, viewClass: any BuilderViewProtocol.Type) {
    if registry[type] == nil {
      registry[type] = viewClass
    }
  }

  public func registerCustomComponent(componentView: any BuilderViewProtocol.Type) {
    registry[componentView.componentType] = componentView
  }

  public func registerCustomComponentInEditor(componentDTO: BuilderCustomComponent, apiKey: String)
  {

  }

}
