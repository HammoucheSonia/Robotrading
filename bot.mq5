#property copyright "Copyright 2023, VotreNom"
#property link      "https://www.votresite.com"
#property version   "1.00"
#property strict


bool initialized = false;
int RSI_Period = 14;
ENUM_TIMEFRAMES timeframe = PERIOD_M1;
double entryThresholdBuy = 7.50;
double entryThresholdSell = 92.50;
double lotSize = 1.0;
int stopLossPoints = 50;

// This is an example of a comment in the Java language.
// int stopLossPoints = 50;

int takeProfitPoints = 30;

// Heures de trading autorisées
const int tradingHourStart = 5;  // Heure de début (5 heures du matin)
const int tradingHourEnd = 22;   // Heure de fin (22 heures le soir)

// Variables pour stocker l'heure de la dernière barre
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialisation du robot
    if (!initialized)
    {
        // Se connecter à la plateforme MT5
        if (!TerminalInfoInteger(TERMINAL_CONNECTED))
        {
            Print("Erreur : Pas de connexion à la plateforme MT5.");
            return INIT_FAILED;
        }

        initialized = true;
    }

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Rien à faire ici
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Vérifier si c'est un jour de la semaine et si l'heure de trading est autorisée
    if (!isTradingTime())
        return;

    // Attendre la clôture d'une nouvelle bougie
    if (!isNewBar())
        return;

    // Obtenir les données nécessaires
    double rsi = iRSI(_Symbol, timeframe, RSI_Period, PRICE_CLOSE);

    // Conditions d'entrée en position
    if (rsi < entryThresholdBuy)
    {
        // Entrée en position à la hausse (achat)
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        double stopLoss = ask - stopLossPoints * _Point;
        double takeProfit = ask + takeProfitPoints * _Point;
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        MqlTradeRequest request;
        MqlTradeResult result;
        ZeroMemory(request);
        ZeroMemory(result);

        request.action = TRADE_ACTION_DEAL;
        request.symbol = _Symbol;
        request.volume = lotSize;
        request.price = bid;
        request.sl = stopLoss;
        request.tp = takeProfit;

        int ticket = OrderSend(request, result);

        if (ticket > 0)
        {
            Print("Ordre d'achat ouvert avec le ticket : ", ticket);
        }
        else
        {
            Print("Erreur lors de l'ouverture de l'ordre d'achat : ", GetLastError());
        }
    }
    else if (rsi > entryThresholdSell)
    {
        // Entrée en position à la baisse (vente)
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double stopLoss = bid + stopLossPoints * _Point;
        double takeProfit = bid - takeProfitPoints * _Point;
        MqlTradeRequest request;
        MqlTradeResult result;
        ZeroMemory(request);
        ZeroMemory(result);
        request.action = TRADE_ACTION_DEAL;
        request.symbol = _Symbol;
        request.volume = lotSize;
        request.price = bid;
        request.sl = stopLoss;
        request.tp = takeProfit;
        int ticket = OrderSend(request, result);

        if (ticket > 0)
        {
            Print("Ordre de vente ouvert avec le ticket : ", ticket);
        }
        else
        {
            Print("Erreur lors de l'ouverture de l'ordre de vente : ", GetLastError());
        }
    }

    // Gestion des positions ouvertes
    // (Vérifier si un ordre a été exécuté, surveiller les mouvements de prix,
    // et fermer les positions lorsque le Stop Loss ou le Take Profit est atteint)
    // ...

    // Retour à la boucle principale
}

//+------------------------------------------------------------------+
//| Vérifie si une nouvelle barre est ouverte                        |
//+------------------------------------------------------------------+
bool isNewBar()
{
    datetime currentBarTime = iTime(_Symbol, timeframe, 0);

    if (currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Vérifie si l'heure de trading est autorisée                       |
//+------------------------------------------------------------------+
bool isTradingTime()
{
    datetime currentHour = (TimeCurrent() / 3600) % 24; // Récupérer l'heure actuelle

    // Vérifier si l'heure actuelle est comprise entre l'heure de début et l'heure de fin de trading
    if (currentHour >= tradingHourStart && currentHour < tradingHourEnd)
    {
        return true;
    }

    return false;
}
