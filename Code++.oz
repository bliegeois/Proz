declare ProjectLib in
[ProjectLib] = {Link ["/Users/Vianney/Documents/LFSAB12/Info/Projet/ProjectLib.ozf"]}

local
   ListOfPersons = {ProjectLib.loadDatabase file "/Users/Vianney/Documents/LFSAB12/Info/Projet/database.txt"}

   fun {BuildDecisionTree L}
      %% @pre: L est une liste de record de forme person(<Atom> <Atom>:<boolean> <Atom>:<boolean> ...)
      %%       où la première valeur est le nom de la personne, et les autres les réponses aux questions
      %%       contenues dans leur champ respectif
      %% @post: retourne un arbre de questions presque optimal de forme
      %%        <DecisionTree> ::= leaf(<List[Atom]>) une liste de nom de personnes
      %%                           | question(<Atom> true:<DecisionTree> false:<DecisionTree>)
      QL={Arity L.1}.2 in
      local
	 fun {Count L Q N}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       Q est un atome qui contient une question
	    %%       N est un entier qui est utilisé comme accumulateur
	    %% @post: retourne le nombre de joueurs pour lesquels la question Q est vraie
	    if L==nil then N
	    else
	       if L.1.Q then {Count L.2 Q N+1}
	       else {Count L.2 Q N} end
	    end
	 end
	 fun {Opti L B I N}
	    %% @pre: L est une liste qui contient le nombre de réponses positives de chaque question
	    %%       B est un entier positif
	    %%       I est un entier utilisé comme itérateur
	    %%       N est un entier utilisé comme accumulateur
	    %% @post: retourne l'indice de la question dont le nombre de réponses positives
	    %%        est le plus proche de la moitié du nombre de joueurs
	    O=({Length L} div 2) in
	    if L==nil then N
	    else
	       if {Abs L.1-O}<{Abs B-O} then {Opti L.2 L.1 I+1 I}
	       else {Opti L.2 B I+1 N} end
	    end
	 end
	 fun {Get L N I}
	    %% @pre: L est une liste
	    %%       N est un entier positif
	    %%       I est un entier utilisé comme itérateur
	    %% @post: retourne l'élément à l'indice N de la liste L
	    if I==N then L.1
	    else {Get L.2 N I+1} end
	 end
	 fun {Remove L LS N I}
	    %% @pre: L est une liste
	    %%       LS est une liste utilisée comme accumulateur
	    %%       N est un entier positif
	    %%       I est un entier utilisé comme itérateur
	    %% @post: retourne une liste qui contient L sans l'élément à l'indice N
	    if I==N then {Append LS L.2}
	    else {Remove L.2 {Append LS [L.1]} N I+1} end
	 end
	 fun {SelectPlayers L Q B SP}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       Q est un atome qui contient une question
	    %%       B est un booléen
	    %%       SP est une liste utilisée comme accumulateur
	    %% @post: retourne la liste des joueurs qui réponde B à la question Q
	    if L==nil then SP
	    else
	       if L.1.Q==B then {SelectPlayers L.2 Q B L.1|SP}
	       else {SelectPlayers L.2 Q B SP} end
	    end
	 end
	 fun {PlayersName L PL}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       PL est une liste utilisée comme accumulateur
	    %% @post: retourne une liste des noms des joueurs contenus dans L
	    if L==nil then PL
	    else {PlayersName L.2 L.1.1|PL} end
	 end
	 fun {ListCount L QL LC}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       QL est une liste de questions
	    %%       LC est une liste utilisée comme accumulateur
	    %% @post: retourne une liste avec le nombre de réponses positives par les joueurs
	    %%        contenus dans L pour chaque question de QL
	    if QL==nil then LC
	    else {ListCount L QL.2 {Append LC [{Count L QL.1 0}]}} end
	 end
	 fun {Build L QL L2 QL2}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       QL est une liste de questions
	    %%       L2 est la liste des joueurs retenus à la séparation précédente
	    %%       QL2 est la liste des questions restantes à la séparation précédente
	    %% @post: retourne un arbre de décision presque optimal
	    if L==nil orelse {Length L}==1 orelse QL==nil then leaf({PlayersName L nil})
	    else
	       LC N BQ QLNew in
	       LC={ListCount L QL nil}
	       N={Opti LC {Length LC}+1 1 1}
	       BQ={Get QL N 1}
	       QLNew={Remove QL nil N 1}
	       question(BQ true:{Build {SelectPlayers L BQ true nil} QLNew L QL} false:{Build {SelectPlayers L BQ false nil} QLNew L QL}
			unknown:{Build L QLNew L QL} oops:[L2 QL2] method:Build)
	    end
	 end
      in
	 {Build L QL L QL}
      end
   end
   fun {GameDriver Tree}
      Result
   in
      case Tree
      of leaf(R) then Result = {ProjectLib.found R}
      [] question(Q true:T1 false:T2 unknown:T3 oops:L method:M) then
	 Ans={ProjectLib.askQuestion Q} in
	 if Ans==oops then {GameDriver {M L.1 L.2.1 L.1 L.2.1} Result}
	 else {GameDriver Tree.Ans Result} end
      end
      %% Toujours retourner unit
      unit
   end    
in
   %% Lancer le jeu
   {ProjectLib.play opts(builder:BuildDecisionTree
			 persons:ListOfPersons
			 driver:GameDriver
			 allowUnknown:true
			 oopsButton:true
			)}
end