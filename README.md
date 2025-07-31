# BuilderIO-Swift

The official Swift SDK to render Builder.io content in your iOS app using SwiftUI.

## Using this SDK

### iOS Compatibility

This SDK supports **iOS 17 and above** to take advantage of the latest SwiftUI capabilities and improved layout behaviors.


### Add Dependency

To integrate the Builder Swift SDK into your iOS App:

1. Add a dependency using the GitHub repository:  
   [https://github.com/BuilderIO/builder-swift](https://github.com/BuilderIO/builder-swift)

2. Point to the `main` branch to always receive the latest SDK updates.

3. Import the SDK wherever you need to access its functionality:
```swift
import BuilderIO

```

4. Besure to call BuilderIOManager.configure pass in your APIKey and optional custom navigation scheme

```swift
BuilderIOManager.configure(apiKey: <YOUR_BUILDER_API_KEY>, customNavigationScheme: "builderio")

```

custom navigation scheme  <CUSTOM_SCHEME>://<MODEL_NAME>/<PAGE_URL>?<OPTIONAL_PARAMETERS> enables navigation within the native SDK between builder pages.

---

### Render Content

#### Render a Full Page

Use `BuilderIOPage` to render a full page from a given Builder URL and Optional evne handler to process onlick events for components.

```swift
BuilderIOPage(url: "/YOUR_TARGET_URL", onClickEventHandler: { builderAction in
            print("Handle Event Action")
          })
```

###### Example:

```swift
var body: some View {
        BuilderIOPage(url: "/YOUR_TARGET_URL")
}
```

You can optionally specify the `model` if you're not using the default `"page"` model.

---

#### Render a Section

Use `BuilderIOContentView` to render content (section views) meant to be embedded in an existing layout:
Compuslory to register environment action handler to handle click events 

```swift
BuilderIOContentView(model: "YOUR_MODEL_NAME")
```

##### Example:

```swift
 @StateObject private var buttonActionManager = BuilderActionManager()
  
  var body: some View {
    
    BuilderIOContentView(model: "hero-section")
      .environmentObject(buttonActionManager)
      .onAppear {
        // Set the action handler
        buttonActionManager.setHandler { builderAction in
          print("Handle Event Action")
        }
      }
    
    
  }
```

---

### Custom Click Handling

To intercept and handle clicks (e.g., for `button` components), you can override the default behavior using `buttonActionManager`:

```swift
BuilderIOPage(url: "/YOUR_TARGET_URL"
    .onAppear {
        buttonActionManager.setHandler { builderAction in
            // Handle your custom action here
            print("Custom Action Triggered: \(builderAction)")
        }
    }
```

---

### (Optional) Register Custom Components

You can register your own custom SwiftUI views to be rendered by Builder using:

```swift
BuilderComponentRegistry.shared.registerCustomComponent(
    componentView: MyCustomComponent.self
)
```

> Replace `MyCustomComponent` with the name of your custom SwiftUI view.

Custom components **must conform** to the `BuilderCustomComponentViewProtocol`.

---

To enable live editing and previewing of your custom components inside the [Builder.io Visual Editor](https://www.builder.io/):

1. Upload a **simulator build** of your app to [Appetize.io](https://appetize.io).
2. Link your **Appetize build ID** in your Builder.io space under **Connected Devices**.
3. Once your Builder.io page loads inside the Appetize-hosted simulator, the component registration will be completed automatically.

This setup enables **real-time editing** and **custom component preview** within Builder’s visual editor.

---

#### Handle Preview Updates from the WebApp

To handle live preview updates:

- Ensure your app is uploaded to **Appetize.io** and **linked** to your Builder.io space.
- Builder.io pushes content updates to the app running in Appetize, allowing you to see changes immediately as you edit.

This supports a **live editing workflow** without the need for rebuilding or redeploying your app for every update.

---

### Fetch Content (Raw Data)

To fetch Builder content manually (e.g., for preview, caching, or custom rendering), use:

```swift
BuilderIOManager.shared
    .fetchBuilderContent(model: "YOUR_MODEL_NAME", url: "/YOUR_TARGET_URL")
```

This returns the raw JSON or decoded model data from Builder.

---


## Complete Example

https://github.com/aarondemelo/BuilderIOExample

---

## Current Support

| Builder Component | Color | Margin / Padding | Horizontal Alignment   | Click Support    |      Unsupported Features       
|-------------------|:-----:|:------------------:|:--------------------:|:--------------:|:-----------------------------------------:
| **Button**        |  ✅   |        ✅         |          ✅           |      ✅       |                                 
| **Text**          |  ✅   |        ✅         |          ✅           |      ✅       |                                 
| **Image**         |  ✅   |        ✅         |          ✅           |      ✅       | Image Position, Lock Aspect Ratio 
| **Columns**       |  ✅   |        ✅         |          ✅           |      ✅       |                                 
| **Sections**      |  ✅   |        ✅         |          ✅           |      ✅       | Lazy Load                      
| **Custom**        |  ✅   |        ✅         |          ✅           |      ✅       |                                 
| **Video**         |  ✅   |        ✅         |          ✅           |      ✅       | When set to Cover, controls not available                                
| **Forms**         |  🏗   |        🏗         |          🏗           |      🏗       |                           


**Unsupported**
JS Code Execution

---

#### Unsupported in Layouts
- Grid Layout with variable sized components


## Contributing
