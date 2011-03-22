#! /bin/bash
obc -c CardsM.m
obc -c RandomizerM.m
obc -c CardsListO.m
obc -c DealerO.m
obc -c UtilsM.m
obc -c UserM.m
obc -o cards CardsM.k RandomizerM.k CardsListO.k DealerO.k UtilsM.k UserM.k
