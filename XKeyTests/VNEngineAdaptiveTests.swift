//
//  VNEngineAdaptiveTests.swift
//  XKeyTests
//
//  Tests for the Adaptive input method (Telex + VNI auto-accept).
//

import XCTest
@testable import XKey

class VNEngineAdaptiveTests: XCTestCase {

    var engine: VNEngine!

    override func setUp() {
        super.setUp()
        engine = VNEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Task 1: enum + settings round-trip

    func testAdaptiveEnumExists() {
        XCTAssertEqual(InputMethod.adaptive.rawValue, 4)
        XCTAssertFalse(InputMethod.adaptive.displayName.isEmpty)
        XCTAssertTrue(InputMethod.allCases.contains(.adaptive))
    }

    func testAdaptiveSettingsRoundTrip() {
        var settings = engine.settings
        settings.inputMethod = .adaptive
        engine.updateSettings(settings)

        XCTAssertTrue(engine.vAdaptiveEnabled, "vAdaptiveEnabled should be set for .adaptive")
        XCTAssertEqual(engine.vInputType, 0, "base vInputType should default to Telex (0)")
        XCTAssertEqual(engine.settings.inputMethod, .adaptive, "reverse mapping should return .adaptive")
    }

    func testNonAdaptiveClearsFlag() {
        var settings = engine.settings
        settings.inputMethod = .adaptive
        engine.updateSettings(settings)
        XCTAssertTrue(engine.vAdaptiveEnabled)

        settings.inputMethod = .vni
        engine.updateSettings(settings)
        XCTAssertFalse(engine.vAdaptiveEnabled, "switching to VNI must clear vAdaptiveEnabled")
        XCTAssertEqual(engine.vInputType, 1)
        XCTAssertEqual(engine.settings.inputMethod, .vni)
    }

    // MARK: - Task 2: dual-typing produces the same Vietnamese output

    /// Helper: type a sequence of (character, keyCode) in adaptive mode and return the word.
    private func typeAdaptive(_ keys: [(Character, UInt16)]) -> String {
        engine.reset()
        engine.vAdaptiveEnabled = true
        engine.vInputType = 0
        for (ch, code) in keys {
            _ = engine.processKey(character: ch, keyCode: code, isUppercase: false)
        }
        return engine.getCurrentWord()
    }

    func testAdaptive_AcuteTone_BothWays() {
        // Telex: a + s  →  á
        XCTAssertEqual(typeAdaptive([("a", VietnameseData.KEY_A), ("s", VietnameseData.KEY_S)]), "á")
        // VNI: a + 1  →  á
        XCTAssertEqual(typeAdaptive([("a", VietnameseData.KEY_A), ("1", VietnameseData.KEY_1)]), "á")
    }

    func testAdaptive_Circumflex_BothWays() {
        // Telex: a + a  →  â
        XCTAssertEqual(typeAdaptive([("a", VietnameseData.KEY_A), ("a", VietnameseData.KEY_A)]), "â")
        // VNI: a + 6  →  â
        XCTAssertEqual(typeAdaptive([("a", VietnameseData.KEY_A), ("6", VietnameseData.KEY_6)]), "â")
    }

    func testAdaptive_Horn_U_BothWays() {
        // Telex: u + w  →  ư
        XCTAssertEqual(typeAdaptive([("u", VietnameseData.KEY_U), ("w", VietnameseData.KEY_W)]), "ư")
        // VNI: u + 7  →  ư
        XCTAssertEqual(typeAdaptive([("u", VietnameseData.KEY_U), ("7", VietnameseData.KEY_7)]), "ư")
    }

    func testAdaptive_Dee_BothWays() {
        // Telex: d + d  →  đ
        XCTAssertEqual(typeAdaptive([("d", VietnameseData.KEY_D), ("d", VietnameseData.KEY_D)]), "đ")
        // VNI: d + 9  →  đ
        XCTAssertEqual(typeAdaptive([("d", VietnameseData.KEY_D), ("9", VietnameseData.KEY_9)]), "đ")
    }
}
