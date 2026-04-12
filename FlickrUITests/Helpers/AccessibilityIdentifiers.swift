// AccessibilityIdentifiers.swift
// FlickrUITests
//
// Mirror of Flickr/Common/AccessibilityIdentifiers.swift.
// UI tests run in a separate process and cannot import the app target,
// so identifier constants are duplicated here.

enum A11y {
    enum Main {
        static let navTitle = "main.navTitle"
        static let toolbarSend = "main.toolbar.send"
        static let toolbarToggleView = "main.toolbar.toggleView"
    }

    enum Search {
        static let field = "search.field"
        static let historyList = "search.history.list"
        static let historyEmpty = "search.history.empty"
        static let historyClear = "search.history.clear"
        static func historyItem(_ text: String) -> String { "search.history.item.\(text)" }
        static func historyDelete(_ text: String) -> String { "search.history.delete.\(text)" }
    }

    enum PhotoList {
        static let list = "photoList.list"
        static let loading = "photoList.loading"
        static let error = "photoList.error"
        static func item(_ id: String) -> String { "photo.item.\(id)" }
        static func deleteButton(_ id: String) -> String { "photo.item.delete.\(id)" }
    }

    enum PageView {
        static let scroll = "pageView.scroll"
        static func page(_ id: String) -> String { "pageView.page.\(id)" }
    }

    enum Editor {
        static let image = "editor.image"
        static let slider = "editor.slider"
        static let angleValue = "editor.angleValue"
        static let save = "editor.save"
    }
}
