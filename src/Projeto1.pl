:- encoding(utf8).
% Majd Qadoura 1117976
:- style_check(-discontiguous). % para nao se queixar descontinuidade da BD
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- ["codigoAuxiliar.pl"]. % Ficheiro dado
:- ["bd_estudantes.pl"]. % Ficheiro dado
:- ["listas_palavras.pl"]. % Ficheiro dado



% Parte 1



% Calcula a média de uma lista de números
media([], 0) :- !.
media(Lista, Media) :-
    % usa o predicado built-in sum_list para somar os elementos da lista e o length para contar o número de elementos
    sum_list(Lista, Soma),
    length(Lista, N),
    %Para evitar divisão por zero
    N > 0,
    %Calcula a média sem arredondamentos e de seguida arredonda usando o predicado arredonda do ficheiro codigoAuxiliar
    MediaTemp is Soma / N,
    arredonda(MediaTemp, Media).

%Calcula a média das notas dos estudantes entre duas idades
mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    %o findall cria uma lista nova que satisfaz as condições dadas
    findall(Nota, (
        %Busca o estudante e a sua idade
        estudante(Id, Idade, _),
        %Se a idade estiver no intervalo, busca a nota do exame
        Idade > IdadeMin,
        Idade =< IdadeMax,
        exame(Id, Nota)
    ), ListaNotas),
    %Faz a media das notas encontradas
    media(ListaNotas, Media).

freqPorGenero(Genero, MediaFreq) :-
    findall(Freq, (
        %Primeiro arranja os estudantes do género dado
        estudante(Id, _, Genero),
        %Depois arranja as frequências desses estudantes
        atividade(Id, _, _, Freq)
        %Finalmente adiciona à lista de frequências
    ), ListaFreqs),
    %Calcula a média das frequências
    media(ListaFreqs, MediaFreq).

alertaSaude(LimSono, LimExerc, LimMental, ListaAlunos) :-
    findall(Id, (
        %Busca os dados de saúde dos estudantes
        saude(Id, Sono, fraca, Exerc, Mental),
        %Verifica se dorme menos que o limite, faz menos exercício que o limite e tem saúde mental abaixo do limite
        Sono < LimSono,
        Exerc < LimExerc,
        Mental < LimMental
        %Se veriifcar as condições, adiciona o Id à lista
    ), ListaIDs),
    %Ordena a lista de IDs
    sort(ListaIDs, ListaAlunos).

probEcraNotasAltas(HorasEcra,ValNota, Probabilidade) :-
    % Encontrar todos os estudantes com horas de ecrã acima do limite(que neste caso é o B na formula)
    findall(Id, (
        atividade(Id, _, Ecra, _),
        Ecra > HorasEcra
    ), ListaB),
    %encontra os estudantes com horas de ecrã acima do limite e notas acima de ValNota (A interseção entre A e B na formula)
    findall(Id, (
        atividade(Id, _, Ecra, _),
        Ecra > HorasEcra,
        exame(Id, Nota),
        Nota > ValNota
    ), ListaIntersecao),
    %Calcula os tamanhos das listas
    length(ListaB, TotalB),
    length(ListaIntersecao, TotalInter),
    %Se o total de B for maior que 0, calcula a probabilidade
    (TotalB > 0 -> 
        P is TotalInter / TotalB 
    %Else, a probabilidade é 0
    ; 
        P is 0
    ),
    arredonda(P, Probabilidade).

%subtraiValorDeLista(Lista, Valor, Resultado)
%Lista vazia devolve lista vazia
subtraiValorDeLista([], _, []).
%A lista é dividida em cabeça(primeiro elemento) e cauda(resto dos elementos)
subtraiValorDeLista([H|T], Valor, [HNovo|TNovo]) :-
    %Subtrai o valor da cabeça
    HNovo is H - Valor,
    %Chama recursivamente para repetir o processo para a cauda
    subtraiValorDeLista(T, Valor, TNovo).

%somaQuadrados(Lista, Resultado)
%Lista vazia tem soma de quadrados 0
somaQuadrados([], 0).
%Lista dividida em cabeça e cauda
somaQuadrados([H|T], Resultado) :-
%Chama recursivamente para a cauda (começando na lista vazia ou seja ResCauda=0 porque nao consegue fazer a soma sem isso e depois volta para trás somando os quadrados por exemplo:[2,3] primeiro chama com []depois com [3] e depois com [2,3])
    somaQuadrados(T, ResCauda),
    Resultado is ResCauda + (H * H).

%produtoEscalar(Lista1, Lista2, Resultado)
%Listas vazias têm produto escalar 0
produtoEscalar([], [], 0).
%Listas divididas em cabeça e cauda
produtoEscalar([H1|T1], [H2|T2], Resultado) :-
    %Chama recursivamente para as caudas das duas listas(mesma lógica que somaQuadrados)
    produtoEscalar(T1, T2, ResCauda),
    %Calcula o produto escalar somando o produto das cabeças ao resultado da cauda
    Resultado is ResCauda + (H1 * H2).

%correlacao(Lista1, Lista2, Resultado)
correlacao(X, Y, Resultado) :-
    %Calcula as médias usando sum_list para somar e length para contar os elementos
    sum_list(X, SomaX), length(X, N), MediaX is SomaX / N, 
    sum_list(Y, SomaY), length(Y, _), MediaY is SomaY / N, 
    
    %Calcula os desvios usando o predicado subtraiValorDeLista(Xi - MediaX) e (Yi - MediaY)
    subtraiValorDeLista(X, MediaX, DesviosX),
    subtraiValorDeLista(Y, MediaY, DesviosY),
    
    %Calcula o numerador usando o produto escalar dos desvios
    produtoEscalar(DesviosX, DesviosY, Numerador),
    
    %Calcula o denominador usando a soma da raiz quadrada(sqrt) da soma dos quadrados dos desvios
    somaQuadrados(DesviosX, SomaQuadX),
    somaQuadrados(DesviosY, SomaQuadY),
    Denominador is sqrt(SomaQuadX) * sqrt(SomaQuadY),
    
    %Calcula a correlação evitando a divisão por zero
    %Se o denominador for maior que 0, calcula a correlação normalmente
    (Denominador > 0 -> 
        R is Numerador / Denominador 
    %Else, a correlação é 0
    ; 
        R is 0
    ),
    %Arredondamento do resultado final
    arredonda(R, Resultado).



% Parte 2



%Devolve o número de letras de uma palavra
tamanho(Palavra, Tamanho) :-
    %verifica se é átomo(fidalgo) ou string("Palhaço") e usa o predicado adequado com um corte(!) por motivos de eficiência(não tenta a outra opção com o mesmo nome se o primeiro funcionar)
    atom(Palavra), !, 
    atom_length(Palavra, Tamanho).
tamanho(Palavra, Tamanho) :-
    string(Palavra), !,
    string_length(Palavra, Tamanho).

%Verifica se ambas as palavras têm o mesmo tamanho e converte-as em listas de caracteres
verificaECalcula(Palavra1, Palavra2, Lista1, Lista2) :-
    %Verifica se têm o mesmo tamanho (=:= comparação numérica)
    tamanho(Palavra1, T1),
    tamanho(Palavra2, T2),
    T1 =:= T2,
    % O predicado auxiliar converte_para_lista converte a palavra em lista de caracteres
    converte_para_lista(Palavra1, Lista1),
    converte_para_lista(Palavra2, Lista2).

% Auxiliar para converter átomo ou string em lista de caracteres usando atom_chars ou string_chars
converte_para_lista(P, L) :- atom(P), !, atom_chars(P, L).
converte_para_lista(P, L) :- string(P), !, string_chars(P, L).

%Conta quantas palavras de tamanho N existem na lista identificada por Id
quantasN(Id, N, Quantas) :-
    %Busca a lista de palavras na base de dados(listas_palavras.pl)
    lista_palavras(Id, Lista),   
    %cria uma nova lista apenas com as palavras que têm tamanho N
    findall(Palavra, (
        %member é built-in e serve para atribuir cada palavra da lista à variável Palavra
        member(Palavra, Lista),   
        tamanho(Palavra, N) 
    ), ListaFiltrada),
    %Conta o número de elementos na lista filtrada
    length(ListaFiltrada, Quantas).

%Conta palavras da lista identificada por Id que começam pelo caracter C
quantasC(Id, C, Quantas) :-
    %Busca a lista de palavras na base de dados
    lista_palavras(Id, Lista),
    findall(Palavra, (
        %unifica cada palavra da lista à variável Palavra
        member(Palavra, Lista),
        %Usa o predicado auxiliar comeca_por para verificar se a palavra começa pelo caracter C
        comeca_por(Palavra, C)
    ), ListaFiltrada),
    %Usamos o sort para eliminar duplicados antes de contar
    sort(ListaFiltrada, ListaUnica),
    length(ListaUnica, Quantas).

%Verifica se a Palavra começa por C 
comeca_por(Palavra, C) :-
    %Extrai a primeira letra da palavra(começa no índice 0, comprimento 1, ignora o resto)
    sub_atom(Palavra, 0, 1, _, PrimeiraLetra),
    %Verifica se a primeira letra é igual a C
    PrimeiraLetra == C.


%apagaElemento(Elemento, Lista, Resultado)
%Lista vazia devolve lista vazia e corta(!)
apagaElemento(_, [], []):- !.
%Apaga o primeiro elemento igual a E e devolve a cauda como resultado usando cut (!) e ignorando o resto
apagaElemento(E, [E|T], T) :- !. 
%Se o elemento da cabeça não for igual a E, mantém a cabeça e continua a procurar na cauda
apagaElemento(E, [H|T], [H|R]) :-
    %Usa recursão para continuar a procurar na cauda e quando encontrar, constroi a lista resultado usando a regra 2 ou regra 1 caso nao encontre
    apagaElemento(E, T, R).

%Devolve lista ordenada de pares (Caracter, Posicao)
posicoesPalavra(Palavra, Posicoes) :-
    %usa o predicado auxiliar para converter a palavra em lista de caracteres
    converte_para_lista(Palavra, ListaCars),
    %nth1 é built-in e devolve o elemento da ListaCars na posição(Pos) dada (1-based index pois começa no 1)
    findall((Car, Pos), nth1(Pos, ListaCars, Car), ListaPares),
    %ordena pelo caracter
    sort(ListaPares, Posicoes). 

% 2 se letras iguais e posição correta, 0 caso contrário
pista1(Palavra1, Palavra2, Pista) :-
    %verifica se as palavras têm o mesmo tamanho e converte-as em listas de caracteres
    verificaECalcula(Palavra1, Palavra2, L1, L2),
    %usa o predicado auxiliar para gerar a pista
    gera_pista1(L1, L2, Pista).

%se as listas estiverem vazias, a pista também é vazia
gera_pista1([], [], []).
%Verifica se a cabeça da primeira lista é igual à cabeça da segunda lista e se for adiciona 2 na cabeça da pista e corta
gera_pista1([C|T1], [C|T2], [2|Resto]) :- !,
    %chama recursivamente para o resto dos caracteres das listas
    gera_pista1(T1, T2, Resto).
%Se as cabeças forem diferentes, adiciona 0 na cabeça da pista
gera_pista1([_|T1], [_|T2], [0|Resto]) :- 
    %continua recursivamente para o resto das caudas
    gera_pista1(T1, T2, Resto).


%2 = Posição correta, 1 = Letra existe algures na palavra mistério, 0 = Letra não existe
pista2(Palavra1, Palavra2, Pista) :-
    verificaECalcula(Palavra1, Palavra2, L1, L2),
    %usa o predicado auxiliar para gerar a pista(passando L1 duas vezes pois o primeiro L1 vai ficando mais curto logo é necessário o segundo(que não é alterado) para verificar existência global)
    gera_pista2(L1, L2, L1, Pista). 
%se as listas estiverem vazias(sem contar com o GlobalL1), a pista também é vazia
gera_pista2([], [], _, []).
%como as cabeças sao iguais, adiciona 2 na cabeça da pista e continua recursivamente
gera_pista2([C|T1], [C|T2], GlobalL1, [2|Resto]) :- !, 
    gera_pista2(T1, T2, GlobalL1, Resto).
%se as cabeças forem diferentes, verifica se a cabeça da segunda lista existe na lista original(GlobalL1) usando a função built-in member e adiciona 1 na cabeça da pista
gera_pista2([_|T1], [X|T2], GlobalL1, [1|Resto]) :-    
    member(X, GlobalL1), !,
    gera_pista2(T1, T2, GlobalL1, Resto).
%se a cabeça da segunda lista não existir na lista original(GlobalL1), adiciona 0 na cabeça da pista
gera_pista2([_|T1], [_|T2], GlobalL1, [0|Resto]) :-
    gera_pista2(T1, T2, GlobalL1, Resto).


pista3(Palavra1, Palavra2, Pista) :-
    %Verifica se as palavras têm o mesmo tamanho e converte-as em listas de caracteres
    verificaECalcula(Palavra1, Palavra2, L1, L2),
    %chamamos o auxiliar passos verdes
    passo_verdes(L1, L2, PistaComVerdes, SobrasL1),
    %chamamos o auxiliar passos amarelos
    passo_amarelos(PistaComVerdes, SobrasL1, Pista).
%Se as listas estiverem vazias, a pista também é vazia e não há sobras
passo_verdes([], [], [], []).
%Se as cabeças forem iguais, adiciona 2 na cabeça da pista e corta(nao continua para a regra seguinte) e continua recursivamente 
passo_verdes([C|T1], [C|T2], [2|RestoPista], SobrasL1) :- !,
    %A letra C foi consumida logo nao é adicionada às sobras
    passo_verdes(T1, T2, RestoPista, SobrasL1).
%Se as cabeças forem diferentes, marca a letra X para ver depois e guarda C nas sobras para ser usado pelos amarelos
passo_verdes([C|T1], [X|T2], [X|RestoPista], [C|SobrasL1]) :- 
    passo_verdes(T1, T2, RestoPista, SobrasL1).
%se a lista de letras da palavra misterio já tiver acabada significa que o jogo acabou e devolve as pistas vazias
passo_amarelos([], _, []).
%Se já estava marcado 2, mantém o 2 e continua recursivamente
passo_amarelos([2|T], Sobras, [2|Resto]) :- !,
    passo_amarelos(T, Sobras, Resto).
%Se o X estava marcado para ver depois e existe nas sobras marca 1
passo_amarelos([X|T], Sobras, [1|Resto]) :-
    %Tenta apagar o elemento X das sobras e se conseguir marca 1 e continua recursivamente
    apagaElemento(X, Sobras, NovasSobras), 
    %Verifica que a lista mudou pois o apaga elemento devolve a lista original se não encontrar o elemento o que faz com que o próximo passo seja marcado como 1 em vez de 0
    Sobras \== NovasSobras,!,
    passo_amarelos(T, NovasSobras, Resto).
%se não existe nas sobras marca 0
passo_amarelos([_|T], Sobras, [0|Resto]) :-
    passo_amarelos(T, Sobras, Resto).



%Parte 3



maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao) :-
    %Garante que a lista tem exatamente 7 elementos(preenchendo com 'empty')
    preenche_com_empty(ListaFilmes, ListaCompleta),
    %O findall recolhe todas as solucoes que satisfazem a permutação e as regras
    findall(Solucao, (
        %usa o predicado built-in permutation para gerar todas as permutações possíveis da lista completa
        permutation(ListaCompleta, Solucao),
        %verifica se a solução cumpre todas as restrições dadas
        verifica_todas_restricoes(ListaRestricoes, Solucao)
    ), SolucoesComDuplicados),
    %Ordenar e remover duplicados 
    sort(SolucoesComDuplicados, Programacao).

%Função auxiliar para preencher a lista com 'empty' até ter 7 elementos
preenche_com_empty(Lista, ListaFinal) :-
    %Se já tem 7 elementos, devolve a lista como está e dá cut
    length(Lista, 7), !,  
    ListaFinal = Lista.

preenche_com_empty(Lista, ListaFinal) :-
    length(Lista, N),
    %Se a lista tiver menos de 7 elementos
    N < 7,
    %Adiciona um 'empty' no fim da lista usando o predicado built-in append      
    append(Lista, [empty], NovaLista),
    %Chama recursivamente até ter 7 elementos
    preenche_com_empty(NovaLista, ListaFinal). % Recursão

%Uma lista de restrições vazia é sempre verdadeira
verifica_todas_restricoes([], _).

%Verifica a cabeça (R) e continua para a cauda (Resto)
verifica_todas_restricoes([R|Resto], Programacao) :-
    satisfaz(R, Programacao),
    %continua recursivamente para o resto das restrições
    verifica_todas_restricoes(Resto, Programacao).


%Predicados para cada tipo de restrição

%terror(Filme):O filme é de terror
%Regra:Só pode passar a partir das 20h
%Sessões:1(14h), 2(17h), 3(20h), 4(23h), 5(14h), 6(17h), 7(20h)
satisfaz(terror(Filme), Programacao) :-
    %Descobre o índice do filme na programação
    nth1(Indice, Programacao, Filme),
    %Verifica se o índice é um dos permitidos (3,4,7)
    member(Indice, [3, 4, 7]).

%soPode(Filme, Sessao):O filme tem de ser naquela posição exata
satisfaz(soPode(Filme, Sessao), Programacao) :-
    %Usa nth1 para verificar se o filme está na sessão correta
    nth1(Sessao, Programacao, Filme).

%nunca(Filme, Sessao):O filme não pode estar naquela posição
satisfaz(nunca(Filme, Sessao), Programacao) :-
    %Usa nth1 para encontrar o índice do filme
    nth1(Indice, Programacao, Filme),
    %Verifica se o índice não é igual à sessão proibida
    Indice \= Sessao.

%seguido(Filme1, Filme2): Filme2 é visto logo a seguir ao Filme1
satisfaz(seguido(Filme1, Filme2), Programacao) :-
    %Usa o predicado built-in nextto para verificar se Filme1 é seguido por Filme2
    nextto(Filme1, Filme2, Programacao). 

%naoSeguido(Filme1, Filme2):Não podem ser vistos seguidos(sem ordem especifica)
satisfaz(naoSeguido(Filme1, Filme2), Programacao) :-
    %Usa o predicado built-in nextto para verificar se Filme1 e Filme2 não são seguidos
    \+ nextto(Filme1, Filme2, Programacao),
    %Mesma verificação na ordem inversa(F2 -> F1)
    \+ nextto(Filme2, Filme1, Programacao).

%antes(Filme1, Filme2): Filme1 aparece antes de Filme2(não necessariamente seguido)
satisfaz(antes(Filme1, Filme2), Programacao) :-
    %Arranja as posições dos filmes na programação
    nth1(I1, Programacao, Filme1),
    nth1(I2, Programacao, Filme2),
    %Posiçao do filme1 tem de ser menor que a do filme2
    I1 < I2.