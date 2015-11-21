% A TESTER!
declare ProjectLib in
[ProjectLib] = {Link ["/Users/Benjamin/Desktop/Proz/ProjectLib.ozf"]}

local
   L = {ProjectLib.loadDatabase file "/Users/Benjamin/Desktop/Proz/database.txt"}

   fun {BuildDecisionTree L}
% construit l'arbre de questions de hauteur presque minimale
      QL={Arity L.1}.2 in
      local
	 fun {Count L Q N}
      % compte le nombre de joueurs pour lesquels la question Q est vraie
	    if L==nil then N
	    else
	       if L.1.Q then {Count L.2 Q N+1}
	       else {Count L.2 Q N} end
	    end
	 end
	 fun {Opti L B I N}
      % choisit la question dont le nombre de réponses positives est le plus proche de la moitié du nombre de joueurs
	    O=({Length L} div 2) in
	    if L==nil then N
	    else
	       if {Abs L.1-O}<{Abs B-O} then {Opti L.2 L.1 I+1 I}
	       else {Opti L.2 B I+1 N} end
	    end
	 end
	 fun {Get L N I}
      % retourne l'élément à l'indice N de L
	    if I==N then L.1
	    else {Get L.2 N I+1} end
	 end
	 fun {Remove L LS N I}
      % retourne une liste qui contient L sans l'élément à l'indice N
	    if I==N then {Append LS L.2}
	    else {Remove L.2 {Append LS [L.1]} N I+1} end
	 end
	 fun {SelectPlayers L Q B SP}
      % retourne la liste des joueurs qui réponde B (booléen) à la question Q
	    if L==nil then SP
	    else
	       if L.1.Q==B then {SelectPlayers L.2 Q B L.1|SP}
	       else {SelectPlayers L.2 Q B SP} end
	    end
	 end
	 fun {PlayersName L PL}
      % retourne la liste des noms des joueurs contenus dans L (qui doit être construit comme la database)
	    if L==nil then PL
	    else {PlayersName L.2 L.1.1|PL} end
	 end
	 fun {ListCount L QL LC}
      % retourne une liste avec le nombre de réponses positives pour chaque question
	    if QL==nil then LC
	    else {ListCount L QL.2 {Append LC [{Count L QL.1 0}]}} end
	 end
	 fun {Build L QL}
	    if QL==nil then leaf({PlayersName L nil})
	    else
	       LC N BQ QLNew in
	       LC={ListCount L QL nil}
	       N={Opti LC {Length LC}+1 1 1}
	       BQ={Get QL N 1}
	       QLNew={Remove QL nil N 1}
	       question(BQ true:{Build {SelectPlayers L BQ true nil} QLNew} false:{Build {SelectPlayers L BQ false nil} QLNew})
	    end
	 end
      in
	 {Build L QL}
      end
   end

   fun {GameDriver Tree}
      Result
   in
      case Tree
      of leaf(R) then Result = {ProjectLib.found R}
      [] question(Q true:T1 false:T2) then {GameDriver Tree.{ProjectLib.askQuestion Q}}
      end
      %% Toujours retourner unit
      unit
   end 
      
in
   %% Lancer le jeu
   {ProjectLib.play opts(builder:BuildDecisionTree
			 persons:L
			 driver:GameDriver
			 %allowUnknown:true %% Décommenter pour ajouter le bouton "Je ne sais pas"
			 %oopsButton:true %% Décommenter pour ajouter le bouton "Oups, j'ai fait une erreur"
			)}
end