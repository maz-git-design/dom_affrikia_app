# Question 1 - Rectangle
class Rectangle:
    def __init__(self, x, y, largeur, hauteur):
        self.x = x
        self.y = y
        self.largeur = largeur
        self.hauteur = hauteur
    
    def surface(self):
        return self.largeur * self.hauteur
    
    def perimetre(self):
        return 2 * (self.largeur + self.hauteur)
    
    def contient(self, point):
        px, py = point
        return (abs(px - self.x) <= self.largeur/2 and 
                abs(py - self.y) <= self.hauteur/2)

# Exercice Question 1
rect = Rectangle(0, 0, 10, 5)
print(f"Point (3,4) dans rectangle: {rect.contient((3, 4))}")
print(f"Surface: {rect.surface()}")
print(f"Périmètre: {rect.perimetre()}")

# Question 2 - Voiture
class Voiture:
    def __init__(self, marque, carburant, consommation):
        self.marque = marque
        self.carburant = carburant
        self.consommation = consommation
    
    def rouler(self, distance):
        carburant_necessaire = distance * self.consommation / 100
        if carburant_necessaire <= self.carburant:
            self.carburant -= carburant_necessaire
        else:
            self.carburant = 0
    
    def faire_le_plein(self, nb_litres):
        self.carburant += nb_litres

# Exercice Question 2
voiture = Voiture("Toyota", 20, 5)
voiture.rouler(300)
print(f"Carburant après 300km: {voiture.carburant}L")
voiture.faire_le_plein(10)
print(f"Carburant après plein: {voiture.carburant}L")

# Question 3 - Inventaire
def ajouter_stock(inventaire, article, quantite):
    if article in inventaire:
        inventaire[article] += quantite
    else:
        inventaire[article] = quantite

# Exercice Question 3
inventaire = {"pomme": 5, "banane": 2}
ajouter_stock(inventaire, "pomme", 3)
ajouter_stock(inventaire, "orange", 4)
print(f"Inventaire: {inventaire}")

# Question 4 - Puissance récursive
def puissance(x, n):
    if n == 0:
        return 1
    return x * puissance(x, n-1)

# Exercice Question 4
print(f"2^10 = {puissance(2, 10)}")
print(f"5^3 = {puissance(5, 3)}")

# Question 5 - Fonctions récursives sur liste
def maximum(liste, index=0):
    if index == len(liste) - 1:
        return liste[index]
    return max(liste[index], maximum(liste, index + 1))

def compter_occurrences(liste, valeur, index=0):
    if index == len(liste):
        return 0
    count = 1 if liste[index] == valeur else 0
    return count + compter_occurrences(liste, valeur, index + 1)

def somme_liste(liste, index=0):
    if index == len(liste):
        return 0
    return liste[index] + somme_liste(liste, index + 1)

# Exercice Question 5
scores = [12, 18, 7, 25, 25, 9, 25, 14]
max_score = maximum(scores)
print(f"Maximum: {max_score}")
print(f"Occurrences du max: {compter_occurrences(scores, max_score)}")
print(f"Somme: {somme_liste(scores)}")

# Question 6 - Jeu
def maj_jeu(jeu):
    joueur_pos = (jeu["joueur"]["x"], jeu["joueur"]["y"])
    
    # Vérifier bonus
    if joueur_pos in jeu["bonus"]:
        jeu["joueur"]["vie"] += 1
        jeu["bonus"].remove(joueur_pos)
    
    # Vérifier pièges
    if joueur_pos in jeu["pieges"]:
        jeu["joueur"]["vie"] -= 1

# Exercice Question 6
jeu = {
    "joueur": {"x": 2, "y": 3, "vie": 3},
    "bonus": [(1,1), (2,3), (4,5)],
    "pieges": [(0,3), (2,4)]
}
maj_jeu(jeu)
print(f"État final du jeu: {jeu}")