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
}
