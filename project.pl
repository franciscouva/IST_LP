% 106340 - Francisco Sousa Uva
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

eventosSemSalas(EventosSemSala) :-
    /* este predicado e verdade se EventosSemSala e uma lista ordenadade IDs unicos,
    tal que os IDs sao identificadores de eventos sem sala atribuida */
    findall(ID, (evento(ID, _, _, _, semSala)), EventosSemSala).


eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) :-
    /*Este predicado e verdade se EventosSemSala e uma lista ordenada de IDs unicos,
    tal que os IDs sao identificadores de eventos sem sala atribuida
    no dia da semana DiaDaSemana */
    findall(
        ID, 
        (evento(ID, _, _, _, semSala), 
            horario(ID, DiaDaSemana, _, _,_, _)),
        EventosSemSala).


eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) :-
    /*Este predicado e verdade se EventosSemSala e uma lista ordenada de IDs unicos,
    tal que os IDs sao identificadores de eventos sem sala atribuida nos periodos
    de ListaPeridos */
    findall(
        ID, 
        (evento(ID, _, _, _, semSala), 
            horario(ID, _, _, _, _, Periodo), 
        (member(Periodo, ListaPeriodos) ; 
            (Periodo = p1_2, 
                (member(p1, ListaPeriodos) ; 
                member(p2, ListaPeriodos))) ; 
            (Periodo = p3_4, 
                (member(p3, ListaPeriodos) ;
                member(p4, ListaPeriodos))))),
        EventosSemSala1),
        removeRepetidos(EventosSemSala1, EventosSemSala).


organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) :-
    /*Este predicado e verdade se EventosNoPeriodo e uma lista ordenada de IDs unicos,
    tal que os IDs sao elementos da lista ListaEventos e sao identificadores de eventos
    que decorrem no periodo Periodo */
    ordenaDesc(ListaEventos, ListaEventosOrdenaDescdo),
    organizaEventos(ListaEventosOrdenaDescdo, Periodo, [], EventosNoPeriodo).
organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([Evento|T], Periodo, EventosNoPeriodoAcc, EventosNoPeriodo) :-
    (horario(Evento, _, _, _, _, Periodo) ; 
    (horario(Evento, _, _, _, _, p1_2), (Periodo = p1 ; Periodo = p2)) ; 
    (horario(Evento, _, _, _, _, p3_4), (Periodo = p3 ; Periodo = p4))),
    organizaEventos(T, Periodo, [Evento|EventosNoPeriodoAcc], EventosNoPeriodo).
organizaEventos([_|T], Periodo, EventosNoPeriodoAcc, EventosNoPeriodo) :-
    organizaEventos(T, Periodo, EventosNoPeriodoAcc, EventosNoPeriodo).

ordenaDesc(List, ListaOrdenada) :-
    trocaDesc(List, List1 ), ! ,
    ordenaDesc(List1, ListaOrdenada) .
ordenaDesc(List, List).
trocaDesc([X,Y|Resto],[Y,X|Resto]) :- X < Y, ! .
trocaDesc([Z|Resto], [Z|Resto1]) :- trocaDesc(Resto,Resto1).


eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    /*Este predicado e verdade se ListaEventosMenoresQue for uma lista ordenada de IDs
    unicos, tal que os IDs sao identificadores de eventos que tem duracao menor ou igual
    Duracao */
    findall(
        ID, 
        (horario(ID, _, _, _, DuracaoEvento, _), 
            DuracaoEvento =< Duracao), 
        ListaEventosMenoresQue).


eventosMenoresQueBool(ID, Duracao) :-
    /*Este predicado e verdade se o evento de identificador ID tiver uma duracao
    menor ou igual a Duracao */
    horario(ID, _, _, _, DuracaoEvento, _),
    DuracaoEvento =< Duracao.


procuraDisciplinas(Curso, ListaDisciplinas) :-
    /*Este predicado e verdade se ListaDisciplinas e uma lista ordenada alfabeticamente
    de disciplinas do curso Curso*/
  findall(
    Disciplina, 
    (turno(ID, Curso, _, _), evento(ID, Disciplina, _, _, _)),
    Disciplinas),
  sort(
    Disciplinas, 
    DisciplinasOrdenaDescdas),
  removeRepetidos(
    DisciplinasOrdenaDescdas, ListaDisciplinas).

removeRepetidos([], []).
removeRepetidos([X|T], Resultado) :-
    /*Este predicado e verdade se Resultado for uma lista sem elementos repetidos*/
    member(X, T),
    !,
    removeRepetidos(T, Resultado).
removeRepetidos([X|T], [X|Resultado]) :-
    removeRepetidos(T, Resultado).


organizaDisciplinas(ListaDisciplinas, Curso, Semestres) :-
    /*Este predicado e verdade se semestres e uma lista de duas listas, tal que a
    primeira lista e a lista, ordenada alfabeticamente, de disciplinas que sao 
    elementos de ListaDisciplinas que decorrem no priemiro semestre do curso Curso,
    e a segunda lista e a lista, ordenada alfabeticamente, de disciplinas que sao
    elementos de ListaDisciplinas que decorrem no segundo semestre do curso Curso */
    organizaDisciplinas(
        ListaDisciplinas, Curso, [], [], Semestre1, Semestre2),
    ordena(Semestre1, Semestre1ordenado),
    ordena(Semestre2, Semestre2ordenado),
    Semestres = [Semestre1ordenado, Semestre2ordenado].
organizaDisciplinas(
    [], _, Semestre1, Semestre2, Semestre1, Semestre2).
organizaDisciplinas(
    [Disciplina|T], Curso, Semestre1, Semestre2, Semestre1Final, Semestre2Final) :-
        turno(ID, Curso, _, _),
        evento(ID, Disciplina, _, _, _),
        horario(ID, _, _, _, _, Periodo),
        (Periodo = p1; Periodo = p2; Periodo = p1_2),
        organizaDisciplinas(
            T, Curso, [Disciplina|Semestre1], Semestre2, Semestre1Final, Semestre2Final).
organizaDisciplinas(
    [Disciplina|T], Curso, Semestre1, Semestre2, Semestre1Final, Semestre2Final) :-
        turno(ID, Curso, _, _),
        evento(ID, Disciplina, _, _, _),
        horario(ID, _, _, _, _, Periodo),
        (Periodo = p3; Periodo = p4; Periodo = p3_4),
        organizaDisciplinas(
            T, Curso, Semestre1, [Disciplina|Semestre2], Semestre1Final, Semestre2Final).

ordena([], []).
ordena(Lista, [Menor|Ordenada]) :-
    /*Este predicado e verdade se o seu segundo argumento e uma lista ordenada 
    (os predicados menor/3 e menor_que_todos/2 sao predicados auxiliares) */
    menor(Lista, Menor, Resto),
    ordena(Resto, Ordenada).

menor([Menor|T], Menor, T) :-
    menor_que_todos(Menor, T).
menor([H|T], Menor, [H|Resto]) :-
    menor(T, Menor, Resto).

menor_que_todos(_, []).
menor_que_todos(Menor, [H|T]) :-
    Menor @< H,
    menor_que_todos(Menor, T).


horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    /*Este predicado e verdade se TotalHoras e o numero total de horas
    de eventos do curso Curso, no ano Ano e no periodo Periodo */
    findall(ID, turno(ID, Curso, Ano, _), IDsCurso),
    removeRepetidos(IDsCurso, IDsCursoUnique),
    findall(
        ID, 
        ((horario(ID, _, _, _, _, Periodo1), 
            (Periodo = Periodo1; (Periodo = p1, Periodo1 = p1_2); 
                                 (Periodo = p2, Periodo1 = p1_2); 
                                 (Periodo = p3, Periodo1 = p3_4); 
                                 (Periodo = p4, Periodo1 = p3_4)))), 
        IDsPeriodo),
    intersection(IDsCursoUnique, IDsPeriodo, IDsLista),
    findall(Duracao, (member(ID, IDsLista), horario(ID, _, _, _, Duracao, _)), Duracoes),
    sumlist(Duracoes, TotalHoras).


evolucaoHorasCurso(Curso, Evolucao) :-
    /*Este predicado e verdade se Evolucao e uma lista ordenada crescentemente 
    por ano e periodo de tuplos da forma (Ano, Periodo, NumHoras), tal que 
    NumHoras e o numero total de horas de eventos do curso Curso, no ano Ano
    e no periodo Periodo */
    ListaAnos = [1, 2, 3],
    ListaPeriodos = [p1, p2, p3, p4],
    findall(
        (Ano, Periodo, Horas), 
        (member(Ano, ListaAnos), 
            member(Periodo, ListaPeriodos), 
            horasCurso(Periodo, Curso, Ano, Horas)), 
        Evolucao).


ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    /*Este predicado e verdade se Horas e o numero de horas sobrepostas entre o
    evento de inicio HoraInicioDada e fim HoraFimDada e o evento com inicio
    HoraInicioEvento e fim HoraFimEvento. No caso de nao haver sobreposicao,
    o predicao e falso */
    HoraInicioEvento < HoraFimDada,
    HoraFimEvento > HoraInicioDada,
    Horas is min(HoraFimDada, HoraFimEvento) - max(HoraInicioDada, HoraInicioEvento).


numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :-
    /*Este predicado e verdade se SomaHoras e o numero de horas ocupadas nas salas
    do tipo TipoSala, entre as horas HoraInicio e HoraFim, no dia da semana DiaSemana
    e no periodo Periodo */
    salas(TipoSala, Salas),
    findall(
        DuracaoEvento, 
        (   evento(ID, _, _, _, Sala), 
            member(Sala, Salas), 
            horario(ID, DiaSemana, HoraInicioEvento, HoraFimEvento, _, PeriodoEvento), 
            (PeriodoEvento = p1_2, Periodo = p1; PeriodoEvento = p1_2, Periodo = p2; 
                PeriodoEvento = p3_4, Periodo = p3; PeriodoEvento = p3_4, Periodo = p4; 
                PeriodoEvento = Periodo), 
            DuracaoEvento is max(0, min(HoraFimEvento, HoraFim) - max(HoraInicioEvento, HoraInicio))),
        Duracoes),
    sumlist(Duracoes, SomaHoras).


ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-
    /*Este predicado e verdade se Max e o numero de horas que podem ser ocupadas nas salas
    do tipo TipoSala entre as horas HoraInicio e HoraFim */
    salas(TipoSala, Salas),
    length(Salas, NumSalas),
    Max is (HoraFim - HoraInicio) * NumSalas.


percentagem(SomaHoras, Max, Percentagem) :-
    /*Este predicado e verdade se Percentagem e a divisao de SomaHoras por Max, 
    multiplicado por 100*/
    Percentagem is (SomaHoras / Max) * 100.