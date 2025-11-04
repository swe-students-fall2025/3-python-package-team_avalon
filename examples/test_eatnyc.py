from importlib.metadata import version as pkg_version
from collections import Counter
from pprint import pprint

from eatnyc import load_data, filter_restaurants, top_n, sample_dish, format_card

def print_header(title: str):
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)

print_header("Version")
print("eatnyc version:", pkg_version("eatnyc"))

# 1) Load data (list[dict])
print_header("Load Data")
data = load_data()
print("raw rows:", len(data))
print("first 3 rows:")
pprint(data[:3])

if not data:
    raise SystemExit("No data loaded. Check bundled CSV and package-data config.")

# 1.1 Explore distinct field values to choose valid filters
print_header("Distinct values (to choose valid filters)")
def distinct(key):
    vals = [ (row.get(key) or "").strip() for row in data ]
    vals = [v for v in vals if v]
    return [v for v,_ in Counter(vals).most_common()]

cuisines = sorted({c for row in data for c in row.get("_cuisines", [])})
neighborhoods = distinct("neighborhood")
prices = distinct("price")

print("cuisines:", cuisines[:15], ("... total %d" % len(cuisines)) if len(cuisines)>15 else "")
print("neighborhoods (sample):", neighborhoods[:10])
print("prices:", prices)

# 2) Filter — use values that exist in your CSV
# Example that should match your sample data:
#   cuisine: "american" exists (4 Charles Prime Rib)
#   neighborhood: "West Village" exists
#   price: "$$$$" exists
print_header("Filter Restaurants (American @ West Village, $$$$, rating>=4.0, limit=10)")
filtered = filter_restaurants(
    data,
    cuisine="American",            # case-insensitive via your normalizer
    neighborhood="West Village",   # must match CSV spelling
    price="$$$$",
    min_rating=4.0,
    limit=10,
)
print("filtered rows:", len(filtered))
pprint(filtered[:3])

# 3) Top-N from filtered
print_header("Top-N (rating desc) from filtered")
top = top_n(filtered, n=5, sort_by="rating", descending=True)
print(f"top size: {len(top)}")
for i, r in enumerate(top, 1):
    print(f"[{i}] {r.get('name')} | {r.get('cuisine')} | {r.get('neighborhood')} | {r.get('price')} | ★{r.get('rating')}")

# 4) Render a card for the first item (ASCII + Markdown)
if top:
    first = top[0]
    print_header("format_card (ASCII)")
    print(format_card(first, style="ascii", width=48, show_dish=True))

    print_header("format_card (Markdown)")
    print(format_card(first, style="markdown", show_dish=True))
else:
    print_header("No results to format (top is empty)")

# 5) Sample dish demo — robust handling of None / error dict / row dict
print_header("sample_dish (try an existing cuisine, e.g. 'american' or 'french')")
sd = sample_dish(cuisine="American", seed=42)

if not sd:
    print("No sample_dish available in dataset.")
elif isinstance(sd, dict) and "error" in sd:
    print("No dish for selected cuisine.")
    print("error:", sd["error"])
    print("suggestions:", sd.get("suggestions"))
else:
    print("Random pick with dish:")
    print(f"{sd.get('name')} — {sd.get('sample_dish')}  "
          f"(cuisine: {sd.get('cuisine')}, rating: {sd.get('rating')})")