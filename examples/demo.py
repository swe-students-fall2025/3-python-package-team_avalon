from eatnyc import load_data, top_n, filter_restaurants, sample_dish, format_card


def main():
    # === Load Data ===
    data = load_data()
    print("rows:", len(data))

    # === Top restaurants by rating ===
    print("\n=== Top 5 by rating (simple print) ===")
    for r in top_n(data, n=5):
        print(f"- {r['name']} ({r['cuisine']}, {r['price']}) ★ {r['rating']} – {r['sample_dish']}")

    # === Top restaurants by rating with format_card ===
    print("\n=== Top 5 by rating (format_card output) ===")
    for r in top_n(data, n=5):
        print(format_card(r, width=60))

    # === Filtering example ===
    print("\n=== Korean restaurants in Koreatown with $$ and rating >= 4.5 (simple print) ===")
    filtered = filter_restaurants(
        data,
        cuisine="Korean",
        neighborhood="Koreatown",
        price="$$",
        min_rating=4.5,
    )
    for r in filtered:
        print(f"- {r['name']} ({r['cuisine']}, {r['price']}) ★ {r['rating']} – {r['sample_dish']}")

    # === Same filter + card display ===
    print("\n=== Same filtered results (format_card output) ===")
    for r in filtered:
        print(format_card(r, width=60))

    # === Sample dish recommendations ===
    print("\n=== Sample dish: Random Italian restaurant ===")
    italian = sample_dish(cuisine="Italian", seed=42)
    if isinstance(italian, dict) and "error" not in italian:
        print(f"Try: {italian['sample_dish']} at {italian['name']}")
        print(format_card(italian, width=60))
    else:
        print(f"{italian['error']}")
        print(f"{italian['message']} {', '.join(italian['suggestions'])}")

    print("\n=== Sample dish: Random restaurant (any cuisine) ===")
    random_restaurant = sample_dish(seed=123)
    if random_restaurant:
        print(f"Try: {random_restaurant['sample_dish']} at {random_restaurant['name']}")
        print(format_card(random_restaurant, width=60))

    print("\n=== Sample dish: Invalid cuisine (should show suggestions) ===")
    invalid = sample_dish(cuisine="Martian")
    if isinstance(invalid, dict) and "error" in invalid:
        print(f"{invalid['error']}")
        print(f"{invalid['message']} {', '.join(invalid['suggestions'][:3])}")


if __name__ == "__main__":
    main()
