fun {GameDriver Tree} % A TESTER!
   Result
in
   case Tree of leaf(R) then Result = {ProjectLib.found R}
   [] question(Q true:T1 false:T2) then
      {GameDriver Tree.{ProjectLib.askQuestion Q}}
   end
   %% Toujours retourner unit
   unit
end 