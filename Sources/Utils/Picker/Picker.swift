// Inspired by https://www.polpiella.dev/how-to-make-an-interactive-picker-for-a-swift-command-line-tool/

import Foundation
import ANSITerminal

struct Picker<T: CustomStringConvertible> {

    internal struct PickerOption {
        let value: T
        let line: Int
    }

    internal struct State {
        var offset: Int
        var activeLine: Int

        init(activeLine: Int = 0, offset: Int = 0) {
            self.activeLine = activeLine
            self.offset = offset
        }
    }

    private let title: String
    private let options: [T]
    private var state: State
    private var shouldBeKilled: Bool

    init(title: String, options: [T]) {
        self.title = title
        self.options = options
        self.state = State()
        self.shouldBeKilled = false
    }

    mutating func pick() -> T? {
        defer {
            cursorOn()
        }
        clearScreen()
        moveTo(0, 0)
        cursorOff()
        ANSITerminal.write(title)
        moveLineDown()

        self.state.offset = readCursorPos().row
        self.state.activeLine = readCursorPos().row
        let pickerOptions = self.options.enumerated().map { PickerOption(value: $1, line: self.state.offset + $0) }

        draw(pickerOptions)
        moveDown()

        let bottomLine = readCursorPos().row

        while true && !shouldBeKilled {
            clearBuffer()
            if keyPressed() {
                let char = readChar()
                if char == NonPrintableChar.enter.char() {
                    break
                }

                let key = readKey()
                if key.code == .up {
                    self.state.activeLine = max(state.activeLine - 1, self.state.offset)
                } else if key.code == .down {
                    state.activeLine = min(state.activeLine + 1, self.state.offset + self.options.count - 1)
                }

                draw(pickerOptions)
            }
        }

        moveTo(bottomLine, 0)
        return shouldBeKilled ? nil : self.options[self.state.activeLine - self.state.offset]
    }

    private func draw(_ options: [PickerOption]) {
        options.forEach { option in
            let isActive = self.state.activeLine == option.line
            write(text: isActive ? "●".lightGreen : "○".foreColor(250), at: (row: option.line, col: 1))
            write(text: isActive ? String(describing: option.value) : String(describing: option.value).foreColor(250), at: (row: option.line, col: 3))
        }
    }

    private func write(text: String, at: (row: Int, col: Int)) {
        moveTo(at.row, at.col)
        ANSITerminal.write(text)
    }

    public mutating func exit() {
        cursorOn()
        self.shouldBeKilled = true
    }
}
