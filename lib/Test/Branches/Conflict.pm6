our %branches is export =
    "master" => q:to/./,
        85904f111123c9152f522715e3a186bb3c8d5f43 (419676d3c14408b303cd27b1739dc854c9cb5f41) Carl Masak cmasak@gmail.com 2019-03-15 23:29:23 +0100
        419676d3c14408b303cd27b1739dc854c9cb5f41 (7f8ccadefe5a4a1a1c6f6052408490c1c07456c8) Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        7f8ccadefe5a4a1a1c6f6052408490c1c07456c8 (436b64b6269f1844b5bfd025a4b9fea7bdee7998) Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        436b64b6269f1844b5bfd025a4b9fea7bdee7998 (a6504f5a2614aedc32d0361c83f67ef5d561cbce) Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        a6504f5a2614aedc32d0361c83f67ef5d561cbce () Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
    "feature-a1" => q:to/./,
        afe42603033bb19be1c8ff6cc92888d46efe22d1 (1e0e2dbd14e635c252c3a0a1a6e5981eea93484e) Carl Masak cmasak@gmail.com 2019-03-18 19:51:28 +0100
        1e0e2dbd14e635c252c3a0a1a6e5981eea93484e (419676d3c14408b303cd27b1739dc854c9cb5f41) Carl Masak cmasak@gmail.com 2019-03-18 19:51:26 +0100
        419676d3c14408b303cd27b1739dc854c9cb5f41 (7f8ccadefe5a4a1a1c6f6052408490c1c07456c8) Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        7f8ccadefe5a4a1a1c6f6052408490c1c07456c8 (436b64b6269f1844b5bfd025a4b9fea7bdee7998) Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        436b64b6269f1844b5bfd025a4b9fea7bdee7998 (a6504f5a2614aedc32d0361c83f67ef5d561cbce) Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        a6504f5a2614aedc32d0361c83f67ef5d561cbce () Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
    "feature-a2" => q:to/./,
        f346768e5c69abff442a8ce5777426ac16ccff65 (cf4e56adbfa90a41f0b69d7d8ca2476992770b3c) Carl Masak cmasak@gmail.com 2019-03-18 19:52:41 +0100
        cf4e56adbfa90a41f0b69d7d8ca2476992770b3c (6627a8a23e4476d366a27e791cd527879c5d507a) Carl Masak cmasak@gmail.com 2019-03-18 19:52:40 +0100
        6627a8a23e4476d366a27e791cd527879c5d507a (afe42603033bb19be1c8ff6cc92888d46efe22d1) Carl Masak cmasak@gmail.com 2019-03-18 19:52:39 +0100
        afe42603033bb19be1c8ff6cc92888d46efe22d1 (1e0e2dbd14e635c252c3a0a1a6e5981eea93484e) Carl Masak cmasak@gmail.com 2019-03-18 19:51:28 +0100
        1e0e2dbd14e635c252c3a0a1a6e5981eea93484e (419676d3c14408b303cd27b1739dc854c9cb5f41) Carl Masak cmasak@gmail.com 2019-03-18 19:51:26 +0100
        419676d3c14408b303cd27b1739dc854c9cb5f41 (7f8ccadefe5a4a1a1c6f6052408490c1c07456c8) Carl Masak cmasak@gmail.com 2019-03-15 23:29:22 +0100
        7f8ccadefe5a4a1a1c6f6052408490c1c07456c8 (436b64b6269f1844b5bfd025a4b9fea7bdee7998) Carl Masak cmasak@gmail.com 2019-03-15 23:29:18 +0100
        436b64b6269f1844b5bfd025a4b9fea7bdee7998 (a6504f5a2614aedc32d0361c83f67ef5d561cbce) Carl Masak cmasak@gmail.com 2019-03-15 23:29:15 +0100
        a6504f5a2614aedc32d0361c83f67ef5d561cbce () Carl Masak cmasak@gmail.com 2019-03-15 23:29:12 +0100
        .
;

our %conflicts is export =
        master => "feature-a1",
;