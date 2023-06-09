# BuilderIO-Swift

The SDK for BuilderIO for iOS in Swift.

## Using this SDK

### Add dependency 

* Add a dependency on the Builder Swift SDK in your iOS App via the Github package: https://github.com/BuilderIO/builder-swift
* Point to the `main` branch of the repository to get the latest and greatest SDK code 
* Import `BuilderIO` wherever you need to use the SDK methods

```
import BuilderIO
```

### (Optional) Register your custom components

Register any components you have created in your iOS App using something like

```
        registerComponent(name: "MyComponentName", factory: { (options, styles) in
            // Return an instance of your view, passing in any
            // properties from Builder to your component for rendering
            return HeroComponent(headingText: options["headingText"].stringValue, ctaText: options["ctaText"].stringValue)
        });
```

* Currently, you will need to replicate this component registration in a JS SDK so that the web preview can render this component and also correctly showcase your custom component to drag and use in Builder. This is a limitation that will be fixed in the future.

## Fetch Content

Based on your targeting requirements, fetch the necessary published content from Builder using `Content.getContent`. You will need to pass in the model name, apiKey, the url and locale to it.

```
Content.getContent(model: "page", 
                   apiKey: "YOUR_BUILDER_API_KEY", 
                   url: "/my-targeting-url", 
                   locale: "", 
                   preview: "") { content in
    // Update your view here
    // Ideally in the main thread
}
```

In the above, replace `page` with your model name (if you have not used the default page model in Builder), and `apiKey` with your API key from Builder.

## Render Content

At the location where you want to render the content fetched from Builder (in a `View`), call the `RenderContent` method with the content fetched via the `Content.getContent` call.


```
RenderContent(content: content.wrappedValue!)
```

## Complete example

For a complete example of an iOS app using the Builder SDK, please refer to https://github.com/BuilderIO/builder/tree/main/examples/swift

You can use this as a base app, and replace the API key in the example with your own to try it out.

## Current Support:


| Builder Component|Color|Margin / Padding|Horizontal Alignment|Click Support|
|------------------|-----|----------------|--------------------|-------------|
| Button  | ✅  | ✅  | ✅  | ✅   |
| Text  | ✅  | ✅  | ✅  | 🏗  |
| Image  | ✅  | ✅  | ✅  | 🏗  |
| Columns  | 🏗  | 🏗  | 🏗  | 🏗  |
| Video  | 🏗  | 🏗  | 🏗  | 🏗  |

## Contributing
