# Test Automatisé Selenium Java pour GreenInvest (Flutter Web)

Ce guide vous fournit le code Java complet pour tester votre application Flutter Web sur Edge via Selenium.

## Pré-requis

1.  **JDK 11+** installé.
2.  **Microsoft Edge WebDriver** (msedgedriver) compatible avec votre version de Edge, ajouté à votre PATH.
3.  **Dépendances Maven** (pom.xml) :

```xml
<dependencies>
    <dependency>
        <groupId>org.seleniumhq.selenium</groupId>
        <artifactId>selenium-java</artifactId>
        <version>4.16.1</version>
    </dependency>
</dependencies>
```

## Stratégie de Test

J'ai ajouté des balises `aria-label` dans votre code Flutter. Selenium va les utiliser pour trouver les éléments.
**Note :** Flutter Web peut être lent à charger. Le script utilise des attentes explicites (`WebDriverWait`).

## Code Java Complet (`GreenInvestTest.java`)

```java
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public class GreenInvestTest {

    static WebDriver driver;
    static WebDriverWait wait;
    static String BASE_URL = "http://localhost:8080"; // Mettez votre URL locale Flutter ici

    public static void main(String[] args) {
        // Configuration du driver Edge
        // Assurez-vous que msedgedriver est dans votre PATH
        driver = new EdgeDriver();
        driver.manage().window().maximize();
        wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            System.out.println("🚀 Démarrage des tests...");

            // --- SCENARIO 1: Porteur de Projet ---
            testScenarioPorteurProjet();

            // --- SCENARIO 2: Admin Validation ---
            testScenarioAdmin();

            // --- SCENARIO 3: Investisseur ---
            testScenarioInvestisseur();

            System.out.println("✅ TOUS LES TESTS SONT PASSÉS !");

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ ECHEC DES TESTS");
        } finally {
            // driver.quit(); // Décommentez pour fermer à la fin
        }
    }

    // --- SCENARIOS ---

    public static void testScenarioPorteurProjet() throws InterruptedException {
        System.out.println("\n--- SCENARIO 1: Porteur de Projet ---");
        driver.get(BASE_URL);
        
        // 1. Inscription
        click("tab_signup");
        type("input_username", "porteur123");
        type("input_email", "porteur123@test.com");
        type("input_password", "password123");
        
        // Sélection du rôle (Click dropdown puis option)
        click("dropdown_role");
        // Note: Flutter dropdowns sont complexes, on clique sur le texte "Porteur de projet" qui apparait
        Thread.sleep(1000); // Petite pause pour l'animation
        // On cherche le texte directement car il sort du semantics tree
        driver.findElement(By.xpath("//*[contains(@aria-label, 'Porteur de projet')]")).click();
        
        click("btn_submit_auth");
        
        // Attente connexion automatique ou redirection
        Thread.sleep(2000);
        
        // 2. Création de projet
        click("btn_create_project_nav");
        
        type("input_project_name", "Projet Solaire Test");
        type("input_project_desc", "Description du projet test selenium");
        type("input_project_amount", "50000");
        type("input_project_counterpart", "Dividendes");
        type("input_project_roi", "12");
        type("input_project_duration", "24");
        
        click("btn_submit_project");
        System.out.println("✅ Projet créé");
        
        // Déconnexion (Simulée par refresh pour l'exemple ou clic menu)
        driver.get(BASE_URL); 
    }

    public static void testScenarioAdmin() throws InterruptedException {
        System.out.println("\n--- SCENARIO 2: Admin ---");
        driver.get(BASE_URL);

        // 1. Login
        click("tab_login");
        type("input_username", "admin"); // Assurez-vous d'avoir un compte admin
        type("input_password", "admin123");
        click("btn_submit_auth");

        Thread.sleep(2000);

        // 2. Validation
        click("card_pending_projects");
        
        // Clique sur le premier projet de la liste
        click("project_item_0"); // Si vous n'avez qu'un projet en attente
        // Ou chercher par nom: driver.findElement(By.xpath("//*[contains(@aria-label, 'Projet Solaire Test')]")).click();

        click("btn_validate_project");
        System.out.println("✅ Projet validé");
        
        driver.get(BASE_URL);
    }

    public static void testScenarioInvestisseur() throws InterruptedException {
        System.out.println("\n--- SCENARIO 3: Investisseur ---");
        driver.get(BASE_URL);

        // 1. Inscription Investisseur
        click("tab_signup");
        type("input_username", "investor99");
        type("input_email", "investor99@test.com");
        type("input_password", "pass123");
        
        // Par défaut c'est investisseur, pas besoin de changer le dropdown
        
        click("btn_submit_auth");
        Thread.sleep(2000);

        // 2. Investir
        // Sur le dashboard, on clique sur un projet (le premier dispo)
        click("btn_view_project_0");
        
        click("btn_invest_now");
        
        // Dialog validation (si simple, sinon ajouter IDs au dialog aussi)
        // Supposons que le dialog a un bouton "Confirmer" standard ou accessible
        // Ajoutez des semantics au dialog si nécessaire
        
        System.out.println("✅ Investissement initié");
    }


    // --- HELPERS ---

    public static void click(String label) {
        // Cherche n'importe quel élément avec cet aria-label
        WebElement el = wait.until(ExpectedConditions.elementToBeClickable(
            By.cssSelector("[aria-label='" + label + "']")
        ));
        el.click();
    }

    public static void type(String label, String text) {
        // Pour les champs texte, Flutter met souvent l'input DANS le semantics container
        // On clique d'abord pour le focus
        WebElement el = wait.until(ExpectedConditions.elementToBeClickable(
            By.cssSelector("[aria-label='" + label + "']")
        ));
        el.click();
        
        // Parfois l'input réel est un enfant ou frère caché
        // Avec Selenium standard sur Flutter, sendKeys sur l'élément parent Semantics fonctionne souvent
        // Sinon il faut chercher la balise <input> active
        
        // Essai direct
        el.sendKeys(text);
    }
}
```

## Astuces pour le Debuggage

*   **Lancer Flutter avec le moteur HTML** : Pour que Selenium voit mieux les éléments, lancez votre app ainsi :
    `flutter run -d chrome --web-renderer html --web-port 8080`
    (Le mode CanvasKit par défaut rend tout en pixels, le mode HTML crée plus de balises réelles).
*   **Inspecteur** : Faites Clic-Droit > Inspecter sur votre app Flutter lancée. Cherchez `aria-label="input_username"`. Si vous le voyez, Selenium le verra.
