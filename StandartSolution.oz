declare ProjectLib in
[ProjectLib] = {Link ["/Users/Benjamin/Desktop/Proz/ProjectLib.ozf"]}

local
   L = {ProjectLib.loadDatabase file "/Users/Benjamin/Desktop/Proz/database.txt"}

   fun {BuildDecisionTree L}
      %% @pre: L est une liste de record de forme person(<Atom> <Atom>:<boolean> <Atom>:<boolean> ...)
      %%       o� la premi�re valeur est le nom de la personne, et les autres les r�ponses aux questions
      %%       contenues dans leur champ respectif
      %% @post: retourne un arbre de questions presque optimal de forme
      %%        <DecisionTree> ::= leaf(<List[Atom]>) une liste de nom de personnes
      %%                           | question(<Atom> true:<DecisionTree> false:<DecisionTree>)
      QL={Arity L.1}.2 in
      local
	 fun {Count L Q N}
	    %% @pre: L est une liste comme d�crite dans BuildDecisionTree
	    %%       Q est un atome qui contient une question
	    %%       N est un entier qui est utilis� comme accumulateur
	    %% @post: retourne le nombre de joueurs pour lesquels la question Q est vraie
	    if L==nil then N
	    else
	       if L.1.Q then {Count L.2 Q N+1}
	       else {Count L.2 Q N} end
	    end
	 end
	 fun {Opti L B I N}
	    %% @pre: L est une liste qui contient le nombre de r�ponses positives de chaque question
	    %%       B est un entier positif
	    %%       I est un entier utilis� comme it�rateur
	    %%       N est un entier utilis� comme accumulateur
	    %% @post: retourne l'indice de la question dont le nombre de r�ponses positives
	    %%        est le plus proche de la moiti� du nombre de joueurs
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
	    %%       I est un entier utilis� comme it�rateur
	    %% @post: retourne l'�l�ment � l'indice N de la liste L
	    if I==N then L.1
	    else {Get L.2 N I+1} end
	 end
	 fun {Remove L LS N I}
	    %% @pre: L est une liste
	    %%       LS est une liste utilis�e comme accumulateur
	    %%       N est un entier positif
	    %%       I est un entier utilis� comme it�rateur
	    %% @post: retourne une liste qui contient L sans l'�l�ment � l'indice N
	    if I==N then {Append LS L.2}
	    else {Remove L.2 {Append LS [L.1]} N I+1} end
	 end
	 fun {SelectPlayers L Q B SP}
	    %% @pre: L est une liste comme d�crite dans BuildDecisionTree
	    %%       Q est un atome qui contient une question
	    %%       B est un bool�en
	    %%       SP est une liste utilis�e comme accumulateur
	    %% @post: retourne la liste des joueurs qui r�ponde B � la question Q
	    if L==nil then SP
	    else
	       if L.1.Q==B then {SelectPlayers L.2 Q B L.1|SP}
	       else {SelectPlayers L.2 Q B SP} end
	    end
	 end
	 fun {PlayersName L PL}
	    %% @pre: L est une liste comme d�crite dans BuildDecisionTree
	    %%       PL est une liste utilis�e comme accumulateur
	    %% @post: retourne une liste des noms des joueurs contenus dans L
	    if L==nil then PL
	    else {PlayersName L.2 L.1.1|PL} end
	 end
	 fun {ListCount L QL LC}
	    %% @pre: L est une liste comme d�crite dans BuildDecisionTree
	    %%       QL est une liste de questions
	    %%       LC est une liste utilis�e comme accumulateur
	    %% @post: retourne une liste avec le nombre de r�ponses positives par les joueurs
	    %%        contenus dans L pour chaque question de QL
	    if QL==nil then LC
	    else {ListCount L QL.2 {Append LC [{Count L QL.1 0}]}} end
	 end
	 fun {Build L QL}
	    %% @pre: L est une liste comme d�crite dans BuildDecisionTree
	    %%       QL est une liste de questions
	    %%       L2 est la liste des joueurs retenus � la s�paration pr�c�dente
	    %%       QL2 est la liste des questions restantes � la s�paration pr�c�dente
	    %% @post: retourne un arbre de d�cision presque optimal
	    if L==nil orelse {Length L}==1 orelse QL==nil
	    then leaf({PlayersName L nil})
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
      case Tree of leaf(R) then Result = {ProjectLib.found R}
      [] question(Q true:T1 false:T2) then
	 {GameDriver Tree.{ProjectLib.askQuestion Q} Result}
      end
      %% Toujours retourner unit
      unit
   end 
      
in
   %% Lancer le jeu
   {ProjectLib.play opts(builder:BuildDecisionTree
			 persons:L
			 driver:GameDriver
			 %allowUnknown:true %% D�commenter pour ajouter le bouton "Je ne sais pas"
			 %oopsButton:true %% D�commenter pour ajouter le bouton "Oups, j'ai fait une erreur"
			)}
end