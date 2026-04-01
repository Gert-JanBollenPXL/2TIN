namespace CardGames.Domain;

public struct Card : ICard
{
    public Card(CardSuit suit, CardRank rank)
    {
        Suit = suit;
        Rank = rank;
    }

    public CardSuit Suit { get; }

    public CardRank Rank { get; }

    public override string ToString()
    {
        return Rank + " of " + Suit;
    }
}