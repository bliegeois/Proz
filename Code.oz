local ProjectLib in
[ProjectLib] = {Link ["ProjectLib.ozf"]}

local
   ListOfPersons = {ProjectLib.loadDatabase file "database.txt"}

   fun {BuildDecisionTree L}
      %% @pre: L est une liste de record de forme person(<Atom> <Atom>:<boolean> <Atom>:<boolean> ...)
      %%       où la première valeur est le nom de la personne, et les autres les réponses aux questions
      %%       contenues dans leur champ respectif
      %% @post: retourne un arbre de questions presque optimal de forme
      %%        <DecisionTree> ::= leaf(<List[Atom]>) une liste de nom de personnes
      %%                           | question(<Atom> true:<DecisionTree> false:<DecisionTree> unknown:<DecisionTree>
      %%                                             oops:<List> method:<Procedure>)
      QL={Arity L.1}.2 in %% liste des questions récupérées chez le premier joueur
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
	 fun {ListCount L QL LC}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       QL est une liste de questions
	    %%       LC est une liste utilisée comme accumulateur
	    %% @post: retourne une liste avec le nombre de réponses positives par les joueurs
	    %%        contenus dans L pour chaque question de QL
	    if QL==nil then LC
	    else {ListCount L QL.2 {Append LC [{Count L QL.1 0}]}} end
	 end
	 fun {Opti L B I N LL}
	    %% @pre: L est une liste qui contient le nombre de réponses positives de chaque question
	    %%       B est un entier positif
	    %%       I est un entier utilisé comme itérateur
	    %%       N est un entier utilisé comme accumulateur
	    %%       LL est la longueur de la liste initiale
	    %% @post: retourne l'indice de la question dont le nombre de réponses positives
	    %%        est le plus proche de la moitié du nombre de joueurs
	    O=(LL div 2) in
	    if L==nil then N
	    else
	       if {Abs L.1-O}<{Abs B-O} orelse {Abs L.1-O}<{Abs B-O}+(LL mod 2) then {Opti L.2 L.1 I+1 I LL}
		  %% l'expression "+(LL mod 2)" sert à prendre en compte
		  %% les répartitions dans les listes de longueur impaire
	       else {Opti L.2 B I+1 N LL} end
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
	 fun {Build L QL L2 QL2}
	    %% @pre: L est une liste comme décrite dans BuildDecisionTree
	    %%       QL est une liste de questions
	    %%       L2 est la liste des joueurs retenus à la séparation précédente
	    %%       QL2 est la liste des questions restantes à la séparation précédente
	    %% @post: retourne un arbre de décision presque optimal
	    if QL==nil then leaf({PlayersName L nil})
	    else
	       LC N BQ QLNew in
	       LC={ListCount L QL nil}
	       N={Opti LC {Length LC}+1 1 1 {Length LC}}
	       BQ={Get QL N 1}
	       QLNew={Remove QL nil N 1}
	       if {SelectPlayers L BQ true nil}==nil orelse {SelectPlayers L BQ false nil}==nil then leaf({PlayersName L nil})
	       else
		  question(BQ true:{Build {SelectPlayers L BQ true nil} QLNew L QL} false:{Build {SelectPlayers L BQ false nil} QLNew L QL}
			   unknown:[L QLNew] oops:[L2 QL2] function:Build)
	       end
	    end
	 end
      in
	 {Build L QL L QL}
      end
   end
   fun {GameDriver Tree}
      %% @pre: Tree est un arbre tel que construit par BuildDecisionTree
      %% @post: renvoie toujours unit et assigne à Result la liste des joueurs répondant
      %%        true aux questions posées en parcourant l'arbre de décision
      Result
   in
      case Tree
      of leaf(R) then Result = {ProjectLib.found R}
      [] question(Q true:T1 false:T2 unknown:L1 oops:L2 function:F) then
	 Ans={ProjectLib.askQuestion Q} in
	 if Ans==oops then {GameDriver {F L2.1 L2.2.1 L2.1 L2.2.1} Result}
	 elseif Ans==unknown then {GameDriver {F L1.1 L1.2.1 L1.1 L1.2.1} Result}
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
			 oopsButton:true)}
end
end
