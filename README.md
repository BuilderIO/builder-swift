# BuilderIO-Swift

The SDK for BuilderIO for iOS in Swift.

## Using this SDK

### Add dependency 

* Add a dependency on the Builder Swift SDK in your iOS App via the Github package: https://github.com/BuilderIO/builder-swift
* Point to the `main` branch of the repository to get the latest and greatest SDK code 
* Import `BuilderIO` wherever you need to use the SDK methods

### (Optional) Register your custom components

Register any components you have created in your iOS App using something like

```
###TODO 
```

## Render Content

At the location where you want to render the content fetched from Builder 

For a standalone page instantiate  

```
BuilderIOPage(apiKey: "<YOUR_BUILDER_API_KEY>", url: "/YOUR_TARGET_URL")
```
In the above, model is optional set to `page` (add if the model you used is not the default page model in Builder)

eg
```
var body: some View {
        NavigationStack {
            BuilderIOPage(apiKey: "<YOUR_BUILDER_API_KEY>", url: "/YOUR_TARGET_URL")
        }
    }
```

For a section instantiate 
```
BuilderIOSection(apiKey:  "<YOUR_BUILDER_API_KEY>", model: "YOUR_MODEL_NAME")
```
eg
```
VStack {
         BuilderIOSection(apiKey: "<YOUR_BUILDER_API_KEY>", model: "YOUR_MODEL_NAME")
       }
```

Alternatively, if you want to override the click handling and want to intercept each `Button` click, then you register the environment buttonActionManager for open links and setHandler for custom actions 

```
  BuilderIOPage(apiKey: "<YOUR_BUILDER_API_KEY>", url: "/YOUR_TARGET_URL").environment(\.buttonActionManager, buttonActionManager)
                .onAppear {
                    buttonActionManager.setHandler { builderAction in
                        print("Handle Event Action")
                    }
                }
```


## Fetch Content 

Based on needs request to raw model data can be gathered by instantiating BuilderIOManager with your API key and requesting the your required model /URL 

```
BuilderIOManager(apiKey:"<YOUR_BUILDER_API_KEY>").fetchBuilderContent(model: String = "YOUR_MODEL_NAME", url: String? =  "/YOUR_TARGET_URL")
```




## Handle Preview Updates from the WebApp

###TODO

## Complete example

For a complete example of an iOS app using the Builder SDK, please refer to ###TODO
You can use this as a base app, and replace the API key in the example with your own to try it out.

## Current Support:


| Builder Component|Color|Margin / Padding|Horizontal Alignment|Click Support|
|------------------|-----|----------------|--------------------|-------------|
| Button  | ✅  | ✅  | ✅  | ✅   |
| Text  | ✅  | ✅  | ✅  | ✅ |
| Image  | ✅  | ✅  | ✅  | ✅ |
| Columns  | ✅  | ✅  | ✅  | ✅  |
| Video  | 🏗  | 🏗  | 🏗  | 🏗  |

## Contributing
