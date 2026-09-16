Feature: Hello World app foundation
  As a user
  I want to see a working Hello World screen
  So that I can verify the Flutter app runs on mobile platforms

  Scenario: App starts and shows the hello world message
    Given the app is launched
    When the home screen loads
    Then I see the text "Hello World!"
    And I see the supporting text "Flutter app foundation ready for Android and iOS."
