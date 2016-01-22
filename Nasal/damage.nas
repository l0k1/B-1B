var incoming_listener = func {
  var history = getprop("/sim/multiplay/chat-history");
  var hist_vector = split("\n", history);
  if (size(hist_vector) > 0) {
    var last = hist_vector[size(hist_vector)-1];
    var last_vector = split(":", last);
    var author = last_vector[0];
    var callsign = getprop("sim/multiplay/callsign");
    if (size(last_vector) > 1 and author != callsign) {
      # not myself
      #print("not me");
      if (1 == 1) { #  getprop("sim/ja37/armament/damage") == 1) {
        # latest version of failure manager and taking damage enabled
        #print("damage enabled");
        var last1 = split(" ", last_vector[1]);
        if(size(last1) > 2 and last1[size(last1)-1] == "exploded" ) {
          #print("missile hitting someone");
          if (size(last_vector) > 3 and last_vector[3] == " "~callsign) {
            #print("that someone is me!");
            var type = last1[1];
            if (type == "Matra") {
              for (var i = 2; i < size(last1)-1; i += 1) {
                type = type~" "~last1[i];
              }
            }
            var number = split(" ", last_vector[2]);
            var distance = num(number[1]);
            #print(type~"|");
            if(distance != nil) {
              var maxDist = 0;

              if (type == "aim-120" or type == "AIM120") {
                # 44 lbs
                maxDist = 20;
              } elsif (type == "aim-7" or type == "RB-71") {
                # 88 lbs
                maxDist = 25;
              } elsif (type == "aim-9" or type == "RB-24J") {
                # 20.8 lbs
                maxDist = 14;
              } elsif (type == "R74") {
                # 16 lbs
                maxDist = 10;
              } elsif (type == "MATRA-R530" or type == "Meteor") {
                # 55 lbs
                maxDist = 22;
              } elsif (type == "AIM-54") {
                # 135 lbs
                maxDist = 30;
              } elsif (type == "Matra R550 Magic 2") {
                # 27 lbs
                maxDist = 17;
              } elsif (type == "Matra MICA") {
                # 30 lbs
                maxDist = 17.5;
              } else {
                return;
              }
              #print("maxDist="~maxDist);
              var diff = maxDist-distance;
              if (diff > 0) {
                diff = diff * diff;
              } else {
                diff = diff * diff;
                diff = diff * -1;
              }
              var probability = diff / (maxDist*maxDist);

              var failure_modes = FailureMgr._failmgr.failure_modes;
              var mode_list = keys(failure_modes);
              var failed = 0;
              foreach(var failure_mode_id; mode_list) {
                if(rand() < probability) {
                  FailureMgr.set_failure_level(failure_mode_id, 1);
                  failed += 1;
                }
              }
              var percent = 100 * probability;
              print("Took "~percent~"% damage from "~type~" missile at "~distance~" meters distance! "~failed~" systems was hit.");
              nearby_explosion();
            }
          } 
        } elsif (last_vector[1] == " KCA cannon shell hit" or last_vector[1] == " Gun Splash On ") {
          # cannon hitting someone
          #print("cannon");
          if (size(last_vector) > 2 and last_vector[2] == " "~callsign) {
            # that someone is me!
            #print("hitting me");

            var probability = 0.20; # take 20% damage from each hit
            var failure_modes = FailureMgr._failmgr.failure_modes;
            var mode_list = keys(failure_modes);
            var failed = 0;
            foreach(var failure_mode_id; mode_list) {
              if(rand() < probability) {
                FailureMgr.set_failure_level(failure_mode_id, 1);
                failed += 1;
              }
            }
            print("Took 20% damage from cannon! "~failed~" systems was hit.");
            nearby_explosion();
          }
        }
      }
    }
  }
}

setlistener("/sim/multiplay/chat-history", incoming_listener, 0, 0);