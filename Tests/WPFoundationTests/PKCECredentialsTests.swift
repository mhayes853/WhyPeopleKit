#if !os(Linux)
  import Testing
  import WPFoundation

  @Suite("PKCECredentials tests")
  struct PKCECredentialsTests {
    @Test(
      "Plain text code challenge initialization",
      arguments: [
        "hello",
        "i am bob + i am not bob /\\.\\",
        "aSBhbSBib2IgKyBpIGFtIG5vdCBib2IgL1wuXA",
        "   hello   ",
        "    ",
        "",
        "hello = world"
      ]
    )
    func plainText(verifier: String) {
      let credentials = PKCECredentials(codeVerifier: verifier, challengeMethod: .plain)
      #expect(credentials.codeVerifier == verifier)
      #expect(credentials.codeChallenge == verifier)
    }

    @Test(
      "SHA256 code challenge initialization",
      arguments: [
        ("hello", "LPJNul-wow4m6DsqxbninhsWHlwfp0JecwQzYpOLmCQ"),
        ("i am bob + i am not bob /\\.\\", "OKf6ocvxPn80QtXo5ApX0QgQLXA46NrPF54GFF_d1fY"),
        ("   hello   ", "3d5eW9AKsgNiSAb9u02KGh9Ma9A48QhTYWevHBA8GuQ"),
        ("    ", "Gg9WTdxgOUV7L7JrPWoxbBXrogqIZEmEfDIQw1ghppM"),
        ("", "47DEQpj8HBSa-_TImW-5JCeuQeRkm5NMpJWZG3hSuFU"),
        ("hello = world", "yViNA93KCr1tQJExn-yXVoptkA9ZnvoOiEt-mqo44KM")
      ]
    )
    func plainText(verifier: String, challenge: String) {
      let credentials = PKCECredentials(codeVerifier: verifier, challengeMethod: .sha256)
      #expect(credentials.codeVerifier == verifier)
      #expect(credentials.codeChallenge == challenge)
    }

    @Test("Random initialization generates random instances")
    func random() throws {
      let c1 = try PKCECredentials()
      let c2 = try PKCECredentials()
      #expect(c1 != c2)
    }

    @Test("Random initialization stays within RFC7636 character length limits.")
    func randomVerifierLength() throws {
      for _ in 0..<100 {
        let credentials = try PKCECredentials()
        #expect((43...128).contains(credentials.codeVerifier.count))
      }
    }
  }
#endif
