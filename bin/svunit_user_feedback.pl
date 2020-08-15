#!/usr/bin/perl

############################################################################
#
#  Copyright 2011 XtremeEDA Corp.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
############################################################################

use strict;

my $FB;
my $fb_file;
my $HI_MSG_THRESHOLD = 200;
my $LO_MSG_THRESHOLD = 10;
my $EMAIL = "neil.johnson\@agilesoc.com";

sub main() {
  if (defined $ENV{"HOME"} and -O $ENV{"HOME"}) {
    $fb_file = $ENV{"HOME"} . "/.svunit";

    if (-e $fb_file) {
      open (FB, "+<$fb_file") or exit 0;
      $_ = <FB>;
      chomp;
      if (m/^[0-9]+$/) {
        if ($_ == $HI_MSG_THRESHOLD) {
          printHi();
        }

        elsif ($_ == $LO_MSG_THRESHOLD) {
          printLo();
        }

        seek FB, 0, 0;
        print FB ++$_ . "\n";
      }
    }

    else {
      open (FB, ">$fb_file") or exit 0;
      print FB "1\n";
    }
    close ( FB, ">$fb_file") or exit 0;
  }
}

sub printHi() {
  print <<WOW
============================================================
============================================================

 WW              WW      OOOOO      WW              WW  !!!
 WW              WW     OOOOOOO     WW              WW  !!!
 WW              WW   OOO     OOO   WW              WW  !!!
 WW              WW  OOO       OOO  WW              WW  !!!
 WW              WW  OOO       OOO  WW              WW  !!!
 WW              WW  OOO       OOO  WW              WW  !!!
 WW              WW  OOO       OOO  WW              WW  !!!
 WW              WW  OOO       OOO  WW              WW  !!!
 WW              WW  OOO       OOO  WW              WW  !!!
 WWW     WW     WWW  OOO       OOO  WWW     WW     WWW  !!!
  WWW    WW    WWW   OOO       OOO   WWW    WW    WWW   !!!
   WWW  WWWW  WWW     OOO     OOO     WWW  WWWW  WWW    !!!
     WWWWWWWWWW         OOOOOOO         WWWWWWWWWW
       WW  WW            OOOOO            WW  WW        !!!


  You've been busy!!

  Sorry again for the interruption, but now that you've
  been using SVUnit for as long as you have, we *really*
  need your help!!

  We need to hear how you're doing with SVUnit so
  please, please, please send us a note at:

              $EMAIL

  Tell us about what you like, what you don't like,
  new features you'd like to see... basically anything
  you think would make SVUnit more valuable to you.
  You're an expert now so your feedback is invaluable
  to us.

  We still don't have a \$1 Million cheque to send you
  but believe me when I say we're working on it. I hope
  by now that because you've been using SVUnit for as
  long as you have, that what you're getting is worth
  \$1 Million.

  ...Ok... Ok... that's probably a stretch, but we're
  glad to see things are working out anyway!

  Thanks again for your help!

  -the creators of SVUnit and other SVUnit experts like you

============================================================
============================================================
WOW
}

sub printLo() {
  print <<HEY
============================================================
============================================================

    HHH       HHH  EEEEEEEEEEEEEE  YYY       YYY    !!!
    HHH       HHH  EEEEEEEEEEEEEE  YYY       YYY    !!!
    HHH       HHH  EEE             YYY       YYY    !!!
    HHH       HHH  EEE             YYY       YYY    !!!
    HHH       HHH  EEE             YYY       YYY    !!!
    HHH       HHH  EEE              YYY     YYY     !!!
    HHHHHHHHHHHHH  EEEEEEEE          YYY   YYY      !!!
    HHHHHHHHHHHHH  EEEEEEEE            YYYYY        !!!
    HHH       HHH  EEE                  YYY         !!!
    HHH       HHH  EEE                  YYY         !!!
    HHH       HHH  EEE                  YYY         !!!
    HHH       HHH  EEE                  YYY         !!!
    HHH       HHH  EEEEEEEEEEEEEE       YYY
    HHH       HHH  EEEEEEEEEEEEEE       YYY         !!!


  Sorry for the interruption, but SVUnit needs your
  help!!

  Now that you've run SVUnit a few times and had a
  chance to kick the tires, we're hoping you'll tell us
  about your experience by sending us a note at:

              $EMAIL

  Tell us about what you like, what you don't like,
  new features you'd like to see... basically anything
  you think would make SVUnit more valuable to you.

  In return, we'd really like to send you a cheque for
  \$1 Million... except that we don't have that kind of
  money... so we can't. Instead, you may have to settle
  for karma and the satisfaction that you've done your
  part to help hardware developers everywhere build
  high quality, defect free hardware.

  ...though obviously if we *do* ever find \$1 Million,
  we'll definitely send you that, too!

  Thanks for your help!

  -the creators of SVUnit and SVUnit users everywhere

  PS: I love your shoes!! Are they new?

============================================================
============================================================
HEY
}

main();
