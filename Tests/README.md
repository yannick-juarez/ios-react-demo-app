# Tests

Ce dossier contient une base de tests unitaires orientee maintenabilite long terme.

## Pourquoi ce dossier est hors AppDemo/React

Le projet n'a pas encore de target de tests Xcode. Placer des fichiers XCTest dans AppDemo/ ou React/ les ferait compiler dans l'app et casserait le build.

## Branchements a faire dans Xcode

1. Creer un target `ReactTests` (Unit Testing Bundle).
2. Ajouter ce dossier `Tests` au target `ReactTests`.
3. Verifier `@testable import React` dans les fichiers de test.

## Portee actuelle

- Domain: smoke tests des modeles coeur.
- Application: use cases (delegation, orchestration simple).
- Infrastructure: mappers/DTO persistants.
- Presentation: view models.
- Composition: wiring DI (`React/Composition`).
