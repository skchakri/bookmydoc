import { application } from "controllers/application"

// Import all controller files
import HelloController from "controllers/hello_controller"
import NotificationController from "controllers/notification_controller"
import AppointmentController from "controllers/appointment_controller"
import AddressAutocompleteController from "controllers/address_autocomplete_controller"
import SpecializationAutocompleteController from "controllers/specialization_autocomplete_controller"
import AvailabilityCalendarController from "controllers/availability_calendar_controller"
import ScrollToBottomController from "controllers/scroll_to_bottom_controller"
import DoctorAutocompleteController from "controllers/doctor_autocomplete_controller"
import SpecializationSearchController from "controllers/specialization_search_controller"

// Register controllers
application.register("hello", HelloController)
application.register("notification", NotificationController)
application.register("appointment", AppointmentController)
application.register("address-autocomplete", AddressAutocompleteController)
application.register("specialization-autocomplete", SpecializationAutocompleteController)
application.register("availability-calendar", AvailabilityCalendarController)
application.register("scroll-to-bottom", ScrollToBottomController)
application.register("doctor-autocomplete", DoctorAutocompleteController)
application.register("specialization-search", SpecializationSearchController)
