import os

project_structure = {
    "lib": {
        "core": {
            "constants": ["colors.dart", "strings.dart"],
            "utils": ["validators.dart", "helpers.dart"],
            "services": ["notification_service.dart", "local_storage_service.dart"],
            "theme": ["app_theme.dart"]
        },
        "data": {
            "models": ["user_model.dart", "tip_model.dart"],
            "datasources": ["firebase_datasource.dart"],
            "repositories": ["user_repository_impl.dart"]
        },
        "domain": {
            "entities": ["user.dart"],
            "repositories": ["user_repository.dart"],
            "usecases": ["get_user_profile.dart"]
        },
        "presentation": {
            "bloc": {
                "user": ["user_bloc.dart", "user_event.dart"]
            },
            "pages": {
                "home": ["home_page.dart"],
                "welcome": ["welcome_page.dart"],
                "tips": ["stress_tips_page.dart"],
                "chatbot": ["happy_bot_page.dart"],
                "sos": ["sos_page.dart"]
            },
            "widgets": ["custom_button.dart", "breathing_card.dart"],
            "routes": ["app_routes.dart"]
        }
    },
    "firebase_options.dart": None,
    "main.dart": None
}

def create_structure(base_path, structure):
    for name, content in structure.items():
        path = os.path.join(base_path, name)
        if isinstance(content, list):
            os.makedirs(path, exist_ok=True)
            for file in content:
                file_path = os.path.join(path, file)
                open(file_path, 'w').close()
        elif isinstance(content, dict):
            os.makedirs(path, exist_ok=True)
            create_structure(path, content)
        elif content is None:
            open(path, 'w').close()

if __name__ == "__main__":
    create_structure(".", project_structure)
    print("Project structure generated successfully.")
