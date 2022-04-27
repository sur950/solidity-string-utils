// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.25 <0.9.0;

import "./Strings.sol";

contract StringsTest {
    using Strings for *;

    function abs(int256 x) private pure returns (int256) {
        if (x < 0) return -x;
        return x;
    }

    function sign(int256 x) private pure returns (int256) {
        return x == 0 ? int256(0) : (x < 0 ? -1 : int256(1));
    }

    function assertEq0(string memory a, string memory b) internal {
        assertEq0(bytes(a), bytes(b));
    }

    function assertEq0(Strings.slice memory a, Strings.slice memory b)
        internal
    {
        assertEq0(a.toString(), b.toString());
    }

    function assertEq0(Strings.slice memory a, string memory b) internal {
        assertEq0(a.toString(), b);
    }

    function testSliceToString() public {
        string memory test = "Hello, world!";
        assertEq0(test, test.toSlice().toString());
    }

    function testBytes32Len() public {
        bytes32 test;
        for (uint256 i = 0; i <= 32; i++) {
            assert(i == test.len(), "Error");
            test = bytes32(
                (uint256(test) / 0x100) |
                    0x2000000000000000000000000000000000000000000000000000000000000000
            );
        }
    }

    function testToSliceB32() public {
        assertEq0(bytes32("foobar").toSliceB32(), "foobar".toSlice());
    }

    function testCopy() public {
        string memory test = "Hello, world!";
        Strings.slice memory s1 = test.toSlice();
        Strings.slice memory s2 = s1.copy();
        s1._len = 0;
        assert(s2._len == bytes(test).length, "Error");
    }

    function testLen() public {
        assert("".toSlice().len() == 0, "Error");
        assert("Hello, world!".toSlice().len() == 13, "Error");
        assert(unicode"naïve".toSlice().len() == 5, "Error");
        assert(unicode"こんにちは".toSlice().len() == 5, "Error");
    }

    function testEmpty() public {
        assert("".toSlice().empty());
        assert(!"x".toSlice().empty());
    }

    function testEquals() public {
        assert("".toSlice().equals("".toSlice()));
        assert("foo".toSlice().equals("foo".toSlice()));
        assert(!"foo".toSlice().equals("bar".toSlice()));
    }

    function testNextRune() public {
        Strings.slice memory s = unicode"a¡ࠀ𐀡".toSlice();
        assertEq0(s.nextRune(), "a");
        assertEq0(s, unicode"¡ࠀ𐀡");
        assertEq0(s.nextRune(), unicode"¡");
        assertEq0(s, unicode"ࠀ𐀡");
        assertEq0(s.nextRune(), unicode"ࠀ");
        assertEq0(s, unicode"𐀡");
        assertEq0(s.nextRune(), unicode"𐀡");
        assertEq0(s, "");
        assertEq0(s.nextRune(), "");
    }

    function testOrd() public {
        assert("a".toSlice().ord() == 0x61);
        assert(unicode"¡".toSlice().ord() == 0xA1);
        assert(unicode"ࠀ".toSlice().ord() == 0x800);
        assert(unicode"𐀡".toSlice().ord() == 0x10021);
    }

    function testCompare() public {
        assert(sign("foobie".toSlice().compare("foobie".toSlice())) == 0);
        assert(sign("foobie".toSlice().compare("foobif".toSlice())) == -1);
        assert(sign("foobie".toSlice().compare("foobid".toSlice())) == 1);
        assert(sign("foobie".toSlice().compare("foobies".toSlice())) == -1);
        assert(sign("foobie".toSlice().compare("foobi".toSlice())) == 1);
        assert(sign("foobie".toSlice().compare("doobie".toSlice())) == 1);
        assert(
            sign(
                "01234567890123456789012345678901".toSlice().compare(
                    "012345678901234567890123456789012".toSlice()
                )
            ) == -1
        );
        assert(
            sign(
                "0123456789012345678901234567890123".toSlice().compare(
                    "1123456789012345678901234567890123".toSlice()
                )
            ) == -1
        );
        assert(
            sign(
                "foo.bar".toSlice().split(".".toSlice()).compare(
                    "foo".toSlice()
                )
            ) == 0
        );
    }

    function testStartsWith() public {
        Strings.slice memory s = "foobar".toSlice();
        assert(s.startsWith("foo".toSlice()));
        assert(!s.startsWith("oob".toSlice()));
        assert(s.startsWith("".toSlice()));
        assert(s.startsWith(s.copy().rfind("foo".toSlice())));
    }

    function testBeyond() public {
        Strings.slice memory s = "foobar".toSlice();
        assertEq0(s.beyond("foo".toSlice()), "bar");
        assertEq0(s, "bar");
        assertEq0(s.beyond("foo".toSlice()), "bar");
        assertEq0(s.beyond("bar".toSlice()), "");
        assertEq0(s, "");
    }

    function testEndsWith() public {
        Strings.slice memory s = "foobar".toSlice();
        assert(s.endsWith("bar".toSlice()));
        assert(!s.endsWith("oba".toSlice()));
        assert(s.endsWith("".toSlice()));
        assert(s.endsWith(s.copy().find("bar".toSlice())));
    }

    function testUntil() public {
        Strings.slice memory s = "foobar".toSlice();
        assertEq0(s.until("bar".toSlice()), "foo");
        assertEq0(s, "foo");
        assertEq0(s.until("bar".toSlice()), "foo");
        assertEq0(s.until("foo".toSlice()), "");
        assertEq0(s, "");
    }

    function testFind() public {
        assertEq0(
            "abracadabra".toSlice().find("abracadabra".toSlice()),
            "abracadabra"
        );
        assertEq0("abracadabra".toSlice().find("bra".toSlice()), "bracadabra");
        assert("abracadabra".toSlice().find("rab".toSlice()).empty());
        assert("12345".toSlice().find("123456".toSlice()).empty());
        assertEq0("12345".toSlice().find("".toSlice()), "12345");
        assertEq0("12345".toSlice().find("5".toSlice()), "5");
    }

    function testRfind() public {
        assertEq0(
            "abracadabra".toSlice().rfind("bra".toSlice()),
            "abracadabra"
        );
        assertEq0("abracadabra".toSlice().rfind("cad".toSlice()), "abracad");
        assert("12345".toSlice().rfind("123456".toSlice()).empty());
        assertEq0("12345".toSlice().rfind("".toSlice()), "12345");
        assertEq0("12345".toSlice().rfind("1".toSlice()), "1");
    }

    function testSplit() public {
        Strings.slice memory s = "foo->bar->baz".toSlice();
        Strings.slice memory delim = "->".toSlice();
        assertEq0(s.split(delim), "foo");
        assertEq0(s, "bar->baz");
        assertEq0(s.split(delim), "bar");
        assertEq0(s.split(delim), "baz");
        assert(s.empty());
        assertEq0(s.split(delim), "");
        assertEq0(".".toSlice().split(".".toSlice()), "");
    }

    function testRsplit() public {
        Strings.slice memory s = "foo->bar->baz".toSlice();
        Strings.slice memory delim = "->".toSlice();
        assertEq0(s.rsplit(delim), "baz");
        assertEq0(s.rsplit(delim), "bar");
        assertEq0(s.rsplit(delim), "foo");
        assert(s.empty());
        assertEq0(s.rsplit(delim), "");
    }

    function testCount() public {
        assert("1121123211234321".toSlice().count("1".toSlice()) == 7);
        assert("ababababa".toSlice().count("aba".toSlice()) == 2);
    }

    function testContains() public {
        assert("foobar".toSlice().contains("f".toSlice()));
        assert("foobar".toSlice().contains("o".toSlice()));
        assert("foobar".toSlice().contains("r".toSlice()));
        assert("foobar".toSlice().contains("".toSlice()));
        assert("foobar".toSlice().contains("foobar".toSlice()));
        assert(!"foobar".toSlice().contains("s".toSlice()));
    }

    function testConcat() public {
        assertEq0("foo".toSlice().concat("bar".toSlice()), "foobar");
        assertEq0("".toSlice().concat("bar".toSlice()), "bar");
        assertEq0("foo".toSlice().concat("".toSlice()), "foo");
    }

    function testJoin() public {
        Strings.slice[] memory parts = new Strings.slice[](4);
        parts[0] = "zero".toSlice();
        parts[1] = "one".toSlice();
        parts[2] = "".toSlice();
        parts[3] = "two".toSlice();

        assertEq0(" ".toSlice().join(parts), "zero one  two");
        assertEq0("".toSlice().join(parts), "zeroonetwo");

        parts = new Strings.slice[](1);
        parts[0] = "zero".toSlice();
        assertEq0(" ".toSlice().join(parts), "zero");
    }
}
