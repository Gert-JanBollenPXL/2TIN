namespace CardGames.Domain;

public class HigherLowerGame
{
    public ICard CurrentCard { get; private set; }
    public ICard? PreviousCard { get; private set; }

    public int NumberOfCorrectGuesses { get; private set; }

    public string? Motivation { get; private set; }

    ICardDeck deck;
    int requiredCorrectGuesses;

    public bool HasWon { get
        {
            if (NumberOfCorrectGuesses == requiredCorrectGuesses)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    public HigherLowerGame(ICardDeck standardDeck, int requiredNumberOfCorrectGuesses, CardRank minimumRank = CardRank.Ace)
    {
        deck = standardDeck.WithoutCardsRankingLowerThan(minimumRank);
        deck.Shuffle();
        CurrentCard = deck.DealCard();
        requiredCorrectGuesses = requiredNumberOfCorrectGuesses;
    }

    public void MakeGuess(bool higher)
    {
        PreviousCard = CurrentCard;
        CurrentCard = deck.DealCard();
        if ((higher && CurrentCard.Rank >= PreviousCard.Rank) || !higher && CurrentCard.Rank <= PreviousCard.Rank)
        {
            NumberOfCorrectGuesses++;
            int guessesNeeded = requiredCorrectGuesses - NumberOfCorrectGuesses;
            if (guessesNeeded <= 3)
            {
                Motivation = guessesNeeded + " correct guesses needed to win!";
            }
            else
            {
                Motivation = null;
            }
        }
        else
        {
            NumberOfCorrectGuesses = 0;
            Motivation = null;
        }

    }
}