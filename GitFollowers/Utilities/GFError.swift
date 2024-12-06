
import Foundation

enum GFError: String, Error {
    case invalidUserName = "This user name created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your request. Pelase check your internet connection and try again."
    case invalidResponse = "Inavlid reponse from server. Please try again."
    case invalidData = "The data received from the server is invalid. Please try again."
    case unableToFavorite = "Unable to favorite user. Please try again."
    case alreadyInFavorites = "You already favourited this user. You must really like them!"
}
