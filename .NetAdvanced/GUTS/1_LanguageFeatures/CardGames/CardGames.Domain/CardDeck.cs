
using System;
using System.Linq;

namespace CardGames.Domain;

public class CardDeck : ICardDeck
{
    public int RemainingCards => _cards.Count;
    private static readonly Random random = new Random();
    private readonly IList<ICard> _cards;

    public CardDeck()
    {
        _cards = new List<ICard>();

        CardSuit[] suits = (CardSuit[])Enum.GetValues(typeof(CardSuit));
        CardSuit[] ranks = (CardSuit[])Enum.GetValues(typeof(CardRank));

        foreach (CardSuit suit in suits)
        {
            foreach (CardRank rank in ranks)
            {
                _cards.Add(new Card(suit, rank));
            }
        }
    }

    private CardDeck(IEnumerable<ICard> collection)
    {
        _cards = new List<ICard>(collection);
    }

    public ICard DealCard()
    {
        if (_cards.Count == 0)
        {
            throw new InvalidOperationException();
        }
        else
        {
            int index = _cards.IndexOf(_cards.Last());
            ICard LastCard = _cards.Last();
            _cards.RemoveAt(index);
            return LastCard;
        }
    }

    public void Shuffle()
    {
        List<ICard> shuffledDeck = new List<ICard>();
        while (_cards.Count > 0)
        {
            int randomIndex = random.Next(_cards.Count);
            ICard selectedCard = _cards[randomIndex];
            _cards.RemoveAt(randomIndex);
            shuffledDeck.Add(selectedCard);
        }

        for (int i = 0; i < shuffledDeck.Count; i++)
        {
            _cards.Add((ICard) shuffledDeck[i]);
        }
    }

    public IList<CardDeck> SplitBySuit()
    {
        IEnumerable<ICard> hearts = _cards.Where(Card => Card.Suit == CardSuit.Hearts);
        IEnumerable<ICard> diamonds = _cards.Where(Card => Card.Suit == CardSuit.Diamonds);
        IEnumerable<ICard> clubs = _cards.Where(Card => Card.Suit == CardSuit.Clubs);
        IEnumerable<ICard> spades = _cards.Where(Card => Card.Suit == CardSuit.Spades);

        CardDeck heartsDeck = new CardDeck(hearts);
        CardDeck diamondsDeck = new CardDeck(diamonds);
        CardDeck clubsDeck = new CardDeck(clubs);
        CardDeck spadesDeck = new CardDeck(spades);

        IList<CardDeck> splitDecks = new List<CardDeck> { heartsDeck, diamondsDeck, clubsDeck, spadesDeck };
        return splitDecks;
    }

    public ICardDeck WithoutCardsRankingLowerThan(CardRank minimumRank)
    {
        IEnumerable<ICard> cards = _cards.Where(card => card.Rank >= minimumRank);
        CardDeck carddeck = new CardDeck(cards);
        return carddeck;
    }
}