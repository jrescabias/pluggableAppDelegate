import ProjectDescription

let infoPlist: InfoPlist = .file(path: "Sources/Configuration/Properties/Info.plist")

let baseSettings: [String: SettingValue] = [
    "PRODUCT_BUNDLE_IDENTIFIER": "$(BUNDLE_ID)",
    "PRODUCT_NAME": "$(APPLICATION_NAME)",
    "GCC_PREPROCESSOR_DEFINITIONS": "$(GCC)"
]

let configs: [Configuration] = [
    .debug(name: "development", xcconfig: "Sources/Configuration/Environments/development.xcconfig"),
    .release(name: "beta", xcconfig: "Sources/Configuration/Environments/beta.xcconfig"),
    .release(name: "production", xcconfig: "Sources/Configuration/Environments/production.xcconfig")
]



let myAppTarget = Target(name: "PluggableAppDelegate",
                         platform: .iOS,
                         product: .app,
                         productName: "PluggableAppDelegate",
                         bundleId: "com.jem.PluggableAppDelegate",
                         deploymentTarget: .iOS(
                            targetVersion: "13.0",
                            devices: .iphone),
                         infoPlist: infoPlist,
                         sources: "Sources/**",
                         resources: "Resources/**",
                         scripts: [
                         ],
                         dependencies: [
                         ],
                         settings: Settings.settings(
                            base: baseSettings,
                            configurations: configs)
)

let autogenerateTarget = Target(name: "Autogenerate",
                                platform: .iOS,
                                product: .app,
                                productName: "Autogenerate",
                                bundleId: "com.jem.autogenerate",
                                infoPlist: .default,
                                scripts: [
                                    .pre(path: "Resources/Internationalization/generateLocalizables", arguments: "https://docs.google.com/spreadsheets/d/16e9zYAW0GfICDP4GBhO1qjfhwn1mFPZz5CL4x1y54P8", name: "LocalizableScript"),
                                    .pre(script: "tuist generate && rm -rf \"$SRCROOT\"/*.lproj", name: "GenerateScript")
                                ])


let targets: [Target] = [
    myAppTarget,
    autogenerateTarget
]

let schemes: [Scheme] = [
    Scheme(name: "PluggableAppDelegate DEV", shared: true, buildAction: BuildAction(targets: ["PluggableAppDelegate"]), runAction: RunAction.runAction(configuration: "development", executable: "PluggableAppDelegate"), archiveAction: .archiveAction(configuration: "development"), profileAction: .profileAction(configuration: "development", executable: "PluggableAppDelegate"), analyzeAction: .analyzeAction(configuration: "development")),
    Scheme(name: "PluggableAppDelegate BETA", shared: true, buildAction: BuildAction(targets: ["PluggableAppDelegate"]), runAction: RunAction.runAction(configuration: "beta", executable: "PluggableAppDelegate"), archiveAction: .archiveAction(configuration: "beta"), profileAction: .profileAction(configuration: "beta", executable: "PluggableAppDelegate"), analyzeAction: .analyzeAction(configuration: "beta")),
    Scheme(name: "PluggableAppDelegate", shared: true, buildAction: BuildAction(targets: ["PluggableAppDelegate"]), runAction: RunAction.runAction(configuration: "production", executable: "PluggableAppDelegate"), archiveAction: .archiveAction(configuration: "production"), profileAction: .profileAction(configuration: "production", executable: "PluggableAppDelegate"), analyzeAction: .analyzeAction(configuration: "production")),
    Scheme(name: "Autogenerate", shared: true, buildAction: BuildAction(targets: ["Autogenerate"]))
]

let project = Project(
    name: "PluggableAppDelegate",
    organizationName: "Jose Escabias",
    packages: [
    ],
    settings: Settings.settings(
        configurations: configs),
    targets: targets,
    schemes: schemes,
    resourceSynthesizers: [
        .assets(),
        .strings()]
)
