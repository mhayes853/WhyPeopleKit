import Foundation
import Testing
import WPSwiftNavigation

@Suite("EmailAddress tests")
struct EmailAddressTests {
  @Test(
    "Valid Emails",
    arguments: [
      "email@domain.com",
      "firstname.lastname@domain.com",
      "email@subdomain.domain.com",
      "firstname+lastname@domain.com",
      "1234567890@domain.com",
      "email@domain-one.com",
      "_______@domain.com",
      "email@domain.name",
      "email@domain.co.jp",
      "firstname-lastname@domain.com",
      "very.common@example.com",
      "disposable.style.email.with+symbol@example.com",
      "other.email-with-hyphen@example.com",
      "fully-qualified-domain@example.com",
      "user.name+tag+sorting@example.com",
      "x@example.com",
      "mojojojo@asdf.example.com",
      "example-indeed@strange-example.com",
      "example@s.example",
      "user-@example.org",
      "user@my-example.com",
      "a@b.cd",
      "work+user@mail.com",
      "tom@test.te-st.com",
      "something@subdomain.domain-with-hyphens.tld",
      "common'name@domain.com",
      "francois@etu.inp-n7.fr"
    ]
  )
  func valid(email: String) {
    #expect(EmailAddress(email)?.rawValue == email)
  }
  
  @Test(
    "Invalid Emails",
    arguments: [
      "francois@@etu.inp-n7.fr",
      #""email"@domain.com"#,
      #""e asdf sadf ?<>ail"@domain.com"#,
      #"" "@example.org"#,
      #""john..doe"@example.org"#,
      #"very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@strange.example.com"#,
      "a,b@domain.com",
      "email@123.123.123.123",
      "email@[123.123.123.123]",
      "postmaster@123.123.123.123",
      "user@[68.185.127.196]",
      "ipv4@[85.129.96.247]",
      "valid@[79.208.229.53]",
      "valid@[255.255.255.255]",
      "valid@[255.0.55.2]",
      "valid@[255.0.55.2]",
      "hgrebert0@[IPv6:4dc8:ac7:ce79:8878:1290:6098:5c50:1f25]",
      "bshapiro4@[IPv6:3669:c709:e981:4884:59a3:75d1:166b:9ae]",
      "jsmith@[IPv6:2001:db8::1]",
      "postmaster@[IPv6:2001:0db8:85a3:0000:0000:8a2e:0370:7334]",
      "postmaster@[IPv6:2001:0db8:85a3:0000:0000:8a2e:0370:192.168.1.1]",
      "plainaddress",
      "#@%^%#$@#$@#.com",
      "@domain.com",
      "Joe Smith &lt;email@domain.com&gt;",
      "email.domain.com",
      "email@domain@domain.com",
      ".email@domain.com",
      "email.@domain.com",
      "email..email@domain.com",
      "あいうえお@domain.com",
      "email@domain.com (Joe Smith)",
      "email@domain",
      "email@-domain.com",
      "email@111.222.333.44444",
      "email@domain..com",
      "Abc.example.com",
      "A@b@c@example.com",
      "colin..hacks@domain.com",
      #"a"b(c)d,e:f;g<h>i[j\k]l@example.com"#,
      #"just"not"right@example.com"#,
      #"this is"not\allowed@example.com"#,
      #"this\ still\"not\\allowed@example.com"#,
      "i_like_underscore@but_its_not_allowed_in_this_part.example.com",
      "QA[icon]CHOCOLATE[icon]@test.com",
      "invalid@-start.com",
      "invalid@end.com-",
      "a.b@c.d",
      "invalid@[1.1.1.-1]",
      "invalid@[68.185.127.196.55]",
      "temp@[192.168.1]",
      "temp@[9.18.122.]",
      "double..point@test.com",
      "asdad@test..com",
      "asdad@hghg...sd...au",
      "asdad@hghg........au",
      "invalid@[256.2.2.48]",
      "invalid@[256.2.2.48]",
      "invalid@[999.465.265.1]",
      "jkibbey4@[IPv6:82c4:19a8::70a9:2aac:557::ea69:d985:28d]",
      "mlivesay3@[9952:143f:b4df:2179:49a1:5e82:b92e:6b6]",
      "gbacher0@[IPv6:bc37:4d3f:5048:2e26:37cc:248e:df8e:2f7f:af]",
      "invalid@[IPv6:5348:4ed3:5d38:67fb:e9b:acd2:c13:192.168.256.1]",
      "test@.com",
      "aaaaaaaaaaaaaaalongemailthatcausesregexDoSvulnerability@test.c"
    ]
  )
  func invalid(email: String) {
    #expect(EmailAddress(email) == nil)
  }
}