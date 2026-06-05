# MongoDB Voorbeeld Examenvragen

## Opgave 1

```javascript
db.bands.find(
    {
        genre: {$all:["Pop", "Disco"]},
        active: true
    },
    {
        singles:0
    }
)
```

## Opgave 2

```javascript
db.band.find(
    {
        founded: {$gte: 1985, $lte: 2000},
        members: {$all: ["Paul Michiels", "Jan Leyers"]}
    }
)
```

## Opgave 3

```javascript
db.bands.find(
    {
        $or: [
            {
                founded: 1972,
                no1hitsBE: { $exists: true }
            },
            {
                "singles.title": /dream/i
            }
        ]
    }
)
```

## Opgave 4

```javascript
db.bands.find(
    {
        $or: [
            { "origin.country": { $in: ["The Netherlands", "Belgium"] } },
            { no1hitsBE: 5 }
        ]
    },
    {
        _id: 1,
        origin: 1,
        no1hitsBE: 1
    }
)
```

## Opgave 5

```javascript
db.bands.find(
    {
        no1hitsNL: {$lte: 15, $gte: 5}
    },
    {
        _id:1,
        members:1
    }
)
.sort({ no1hitsNL: -1 })
.skip(7)
.limit(2)
```

## Opgave 6

```javascript
db.bands.find(
    {
        genre: /rock$/i
    }
)
.sort({founded: -1})
.skip(2)
.limit(3)
```

## Opgave 7

```javascript
db.bands.updateMany(
    {
        no1hitsBE: 1,
        founded: {$in: [1972, 1976]}
    },
    {
        $set: {
            language: "English"
        }
    }
)
```

## Opgave 8

```javascript
db.bands.updateMany(
    {
        no1hitsNL: {$exists: false}
    },
    {
        $addToSet: {
            genre: {
                $each: ["Pop", "Poprock"]
            }
        }
    }
)
```

## Opgave 9

```javascript
db.bands.insertMany(
    [
        {
            _id: "Hooverphonic",
            founded: ISODate("1995-05-15"),
            members: ["Alex Callier", "Luka Cruysberghs"]
        },
        {
            _id: "Milow",
            active: true,
            singles: [
                {title: "You Don’t Know", released: 2007},
                {title: "Ayo Technology", released: 2008}
            ]
        }
    ]
)
```

## Opgave 10

```javascript
db.bands.updateMany(
    {
        founded: { $lt: 1970 },
        active: { $exists: false }
    },
    {
        $set: {
            stopped: true
        }
    }
)
```

## Opgave 11

```javascript
db.bands.find(
    {
        "genre.0": "Pop",
        "origin.country": {$in: ["Sweden", "UK"]}
    }
)
.count()
```

### Of

```javascript
db.bands.countDocuments({
    "genre.0": "Pop",
    "origin.country": { $in: ["Sweden", "UK"] }
})
```

## Opgave 12

```javascript
db.bands.find(
    {
        $or: [
            {
                _id: /^A/,
                no1hitsNL: {$exists: false}
            },
            {
                genre: {$all: ["Pop", "Disco"]}
            }
        ]
    },
    {
        _id: 1,
        genre: 1,
        members: 1
    }
)
```

## Opgave 13

```javascript
db.bands.find(
    {
        no1hitsBE: {$gte: 2},
        no1hitsNL: {$gte: 2}
    },
)
.sort({founded: -1, _id: 1})
.skip(4)
.limit(6)
```