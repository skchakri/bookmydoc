# Clear existing data
puts "Clearing existing data..."
Message.delete_all
Review.delete_all
Award.delete_all
UnavailableDate.delete_all
AuditLog.delete_all
Notification.delete_all
TestResultUpload.delete_all
TestOrder.delete_all
Appointment.delete_all
AppointmentSlot.delete_all
SymptomReport.delete_all
User.delete_all

puts "Creating users..."

# Create Admin User
admin = User.create!(
  full_name: "Admin User",
  phone_number: "+919999999999",
  email: "admin@bookmydoc.in",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  location_city: "Mumbai",
  location_pin_code: "400001",
  latitude: 19.0760,
  longitude: 72.8777,
  is_verified: true,
  phone_verified_at: Time.current
)

puts "✓ Admin created: #{admin.phone_number} / password123"

# Create Doctor 1 - Cardiologist in Mumbai
doctor1 = User.create!(
  full_name: "Dr. Rajesh Kumar",
  phone_number: "+919876543210",
  email: "rajesh.kumar@bookmydoc.in",
  password: "doctor123",
  password_confirmation: "doctor123",
  role: :doctor,
  specialization: "Cardiologist",
  location_city: "Mumbai",
  location_pin_code: "400050",
  latitude: 19.0596,
  longitude: 72.8295,
  consultation_fee_initial: 500,
  consultation_fee_due: 1500,
  clinic_address: "Heart Care Clinic, Bandra West, Mumbai - 400050",
  about_bio: "Experienced cardiologist with 15+ years of practice. Specializing in heart disease prevention and treatment.",
  medical_registration_number: "MH-12345",
  aadhaar_number: "1234-5678-9012",
  years_of_experience: 15,
  is_verified: true,
  phone_verified_at: Time.current,
  aadhaar_verified_at: Time.current
)

puts "✓ Doctor 1 created: #{doctor1.full_name} (#{doctor1.specialization})"
puts "  Phone: #{doctor1.phone_number} / password: doctor123"

# Create Doctor 2 - ENT Specialist in Delhi
doctor2 = User.create!(
  full_name: "Dr. Priya Sharma",
  phone_number: "+919876543211",
  email: "priya.sharma@bookmydoc.in",
  password: "doctor123",
  password_confirmation: "doctor123",
  role: :doctor,
  specialization: "ENT",
  location_city: "Delhi",
  location_pin_code: "110001",
  latitude: 28.6139,
  longitude: 77.2090,
  consultation_fee_initial: 300,
  consultation_fee_due: 700,
  clinic_address: "ENT Care Center, Connaught Place, New Delhi - 110001",
  about_bio: "ENT specialist with expertise in ear, nose, and throat disorders. Committed to providing quality care.",
  medical_registration_number: "DL-67890",
  aadhaar_number: "9876-5432-1098",
  years_of_experience: 10,
  is_verified: true,
  phone_verified_at: Time.current,
  aadhaar_verified_at: Time.current
)

puts "✓ Doctor 2 created: #{doctor2.full_name} (#{doctor2.specialization})"
puts "  Phone: #{doctor2.phone_number} / password: doctor123"

# Create Doctor 3 - Dermatologist in Mumbai
doctor3 = User.create!(
  full_name: "Dr. Anita Desai",
  phone_number: "+919876543212",
  email: "anita.desai@bookmydoc.in",
  password: "doctor123",
  password_confirmation: "doctor123",
  role: :doctor,
  specialization: "Dermatologist",
  location_city: "Mumbai",
  location_pin_code: "400060",
  latitude: 19.0728,
  longitude: 72.8826,
  consultation_fee_initial: 400,
  consultation_fee_due: 800,
  clinic_address: "Skin Care Clinic, Andheri East, Mumbai - 400060",
  about_bio: "Dermatologist specializing in skin, hair, and nail conditions. Expert in cosmetic dermatology.",
  medical_registration_number: "MH-34567",
  aadhaar_number: "2345-6789-0123",
  years_of_experience: 8,
  is_verified: true,
  phone_verified_at: Time.current,
  aadhaar_verified_at: Time.current
)

puts "✓ Doctor 3 created: #{doctor3.full_name} (#{doctor3.specialization})"
puts "  Phone: #{doctor3.phone_number} / password: doctor123"

# Create Patient 1
patient1 = User.create!(
  full_name: "Amit Patel",
  phone_number: "+919123456789",
  email: "amit.patel@example.com",
  password: "patient123",
  password_confirmation: "patient123",
  role: :patient,
  location_city: "Mumbai",
  location_pin_code: "400070",
  latitude: 19.1197,
  longitude: 72.9081,
  address: "123 Marine Drive, Mumbai - 400070",
  is_verified: true,
  phone_verified_at: Time.current
)

puts "✓ Patient 1 created: #{patient1.full_name}"
puts "  Phone: #{patient1.phone_number} / password: patient123"

# Create Patient 2
patient2 = User.create!(
  full_name: "Sneha Reddy",
  phone_number: "+919123456788",
  email: "sneha.reddy@example.com",
  password: "patient123",
  password_confirmation: "patient123",
  role: :patient,
  location_city: "Delhi",
  location_pin_code: "110021",
  latitude: 28.5355,
  longitude: 77.3910,
  address: "456 Defence Colony, Delhi - 110021",
  is_verified: true,
  phone_verified_at: Time.current
)

puts "✓ Patient 2 created: #{patient2.full_name}"
puts "  Phone: #{patient2.phone_number} / password: patient123"

# Create Patient 3
patient3 = User.create!(
  full_name: "Rahul Verma",
  phone_number: "+919123456787",
  email: "rahul.verma@example.com",
  password: "patient123",
  password_confirmation: "patient123",
  role: :patient,
  location_city: "Mumbai",
  location_pin_code: "400080",
  latitude: 19.0895,
  longitude: 72.8634,
  address: "789 Powai, Mumbai - 400080",
  is_verified: true,
  phone_verified_at: Time.current
)

puts "✓ Patient 3 created: #{patient3.full_name}"
puts "  Phone: #{patient3.phone_number} / password: patient123"

# Create Awards for Doctors
puts "\nCreating doctor awards..."

Award.create!(
  doctor: doctor1,
  title: "Best Cardiologist Award 2022",
  issuing_organization: "Indian Medical Association",
  date_received: Date.new(2022, 11, 15),
  description: "Awarded for outstanding service in cardiology and patient care"
)

Award.create!(
  doctor: doctor1,
  title: "Excellence in Cardiac Care",
  issuing_organization: "Mumbai Medical Society",
  date_received: Date.new(2023, 8, 20),
  description: "Recognition for excellence in cardiac care and research"
)

Award.create!(
  doctor: doctor2,
  title: "Outstanding ENT Specialist",
  issuing_organization: "Delhi Medical Council",
  date_received: Date.new(2023, 5, 10),
  description: "Award for exceptional work in ENT treatments and surgeries"
)

Award.create!(
  doctor: doctor3,
  title: "Best Dermatologist Award",
  issuing_organization: "Indian Dermatology Association",
  date_received: Date.new(2021, 12, 5),
  description: "Excellence in dermatological care and cosmetic treatments"
)

puts "✓ Awards created for doctors"

# Create Unavailable Dates
puts "\nCreating unavailable dates..."

# Doctor 1 unavailable on next Sunday
next_sunday = Date.today + (7 - Date.today.wday).days
UnavailableDate.create!(
  doctor: doctor1,
  date: next_sunday,
  reason: "Personal leave"
)

# Doctor 2 unavailable on a specific date
UnavailableDate.create!(
  doctor: doctor2,
  date: 10.days.from_now.to_date,
  reason: "Attending medical conference"
)

puts "✓ Unavailable dates created"

# Create Appointment Slots for Doctor 1
puts "\nCreating appointment slots..."

# Monday to Friday, 9 AM to 12 PM
(0..14).each do |day_offset|
  date = Date.today + day_offset.days
  next if date.saturday? || date.sunday?
  next if UnavailableDate.exists?(doctor: doctor1, date: date)

  doctor1.appointment_slots.create!(
    start_time: date.to_time.change(hour: 9, min: 0),
    end_time: date.to_time.change(hour: 12, min: 0),
    frequency_minutes: 15,
    is_open: true
  )

  # Afternoon slot: 3 PM to 6 PM
  doctor1.appointment_slots.create!(
    start_time: date.to_time.change(hour: 15, min: 0),
    end_time: date.to_time.change(hour: 18, min: 0),
    frequency_minutes: 15,
    is_open: true
  )
end

puts "✓ Created appointment slots for Dr. #{doctor1.full_name}"

# Create Appointment Slots for Doctor 2
(0..14).each do |day_offset|
  date = Date.today + day_offset.days
  next if date.saturday? || date.sunday?
  next if UnavailableDate.exists?(doctor: doctor2, date: date)

  doctor2.appointment_slots.create!(
    start_time: date.to_time.change(hour: 10, min: 0),
    end_time: date.to_time.change(hour: 13, min: 0),
    frequency_minutes: 20,
    is_open: true
  )

  # Evening slot: 4 PM to 7 PM
  doctor2.appointment_slots.create!(
    start_time: date.to_time.change(hour: 16, min: 0),
    end_time: date.to_time.change(hour: 19, min: 0),
    frequency_minutes: 20,
    is_open: true
  )
end

puts "✓ Created appointment slots for Dr. #{doctor2.full_name}"

# Create Appointment Slots for Doctor 3
(0..14).each do |day_offset|
  date = Date.today + day_offset.days
  next if date.saturday? || date.sunday?

  doctor3.appointment_slots.create!(
    start_time: date.to_time.change(hour: 11, min: 0),
    end_time: date.to_time.change(hour: 14, min: 0),
    frequency_minutes: 30,
    is_open: true
  )

  # Evening slot: 5 PM to 8 PM
  doctor3.appointment_slots.create!(
    start_time: date.to_time.change(hour: 17, min: 0),
    end_time: date.to_time.change(hour: 20, min: 0),
    frequency_minutes: 30,
    is_open: true
  )
end

puts "✓ Created appointment slots for Dr. #{doctor3.full_name}"

# Create Symptom Reports
puts "\nCreating symptom reports..."

symptom_report1 = patient1.symptom_reports.create!(
  free_text_description: "I have been experiencing chest pain and shortness of breath for the past 2 days. Sometimes feel palpitations.",
  ai_predicted_condition: "Possible cardiac condition",
  ai_recommended_specializations: ["Cardiologist", "General Physician"]
)

puts "✓ Symptom report created for #{patient1.full_name}"

symptom_report2 = patient2.symptom_reports.create!(
  free_text_description: "Having severe sore throat, ear pain and difficulty swallowing. Also experiencing nasal congestion.",
  ai_predicted_condition: "Possible ENT related infection",
  ai_recommended_specializations: ["ENT", "General Physician"]
)

puts "✓ Symptom report created for #{patient2.full_name}"

symptom_report3 = patient3.symptom_reports.create!(
  free_text_description: "Experiencing itchy rash on arms and legs. Red patches appearing. Started 3 days ago.",
  ai_predicted_condition: "Possible allergic reaction or dermatitis",
  ai_recommended_specializations: ["Dermatologist", "General Physician"]
)

puts "✓ Symptom report created for #{patient3.full_name}"

# Create Appointments
puts "\nCreating appointments..."

# Past completed appointment for patient1 with doctor1
past_appointment1 = Appointment.create!(
  doctor: doctor1,
  patient: patient1,
  scheduled_start: 7.days.ago.change(hour: 10, min: 0),
  scheduled_end: 7.days.ago.change(hour: 10, min: 30),
  status: :completed,
  payment_status: :paid,
  initial_fee_amount: doctor1.consultation_fee_initial,
  remaining_fee_amount: 0,
  doctor_notes: "Patient presented with chest discomfort. ECG normal. Recommended lifestyle changes and follow-up in 3 months. Prescribed aspirin 75mg daily.",
  patient_notes: "Felt chest pain occasionally"
)

puts "✓ Past appointment created (completed)"

# Past completed appointment for patient2 with doctor2
past_appointment2 = Appointment.create!(
  doctor: doctor2,
  patient: patient2,
  scheduled_start: 5.days.ago.change(hour: 16, min: 0),
  scheduled_end: 5.days.ago.change(hour: 16, min: 20),
  status: :completed,
  payment_status: :paid,
  initial_fee_amount: doctor2.consultation_fee_initial,
  remaining_fee_amount: 0,
  doctor_notes: "Diagnosed with acute pharyngitis. Prescribed antibiotics and anti-inflammatory medication. Advised to return if symptoms persist after 3 days.",
  patient_notes: "Throat pain and fever"
)

puts "✓ Past appointment 2 created (completed)"

# Upcoming confirmed appointment
upcoming_appointment1 = Appointment.create!(
  doctor: doctor1,
  patient: patient1,
  scheduled_start: 2.days.from_now.change(hour: 15, min: 0),
  scheduled_end: 2.days.from_now.change(hour: 15, min: 30),
  status: :confirmed,
  payment_status: :partial_paid,
  initial_fee_amount: doctor1.consultation_fee_initial,
  remaining_fee_amount: doctor1.consultation_fee_due,
  patient_notes: "Follow-up appointment for test results"
)

puts "✓ Upcoming appointment created (confirmed)"

# Today's appointment for Doctor 2
today_appointment = Appointment.create!(
  doctor: doctor2,
  patient: patient2,
  scheduled_start: Time.current.change(hour: 16, min: 0),
  scheduled_end: Time.current.change(hour: 16, min: 20),
  status: :confirmed,
  payment_status: :partial_paid,
  initial_fee_amount: doctor2.consultation_fee_initial,
  remaining_fee_amount: doctor2.consultation_fee_due,
  patient_notes: "Sore throat and ear pain follow-up"
)

puts "✓ Today's appointment created"

# Upcoming appointment with doctor3
upcoming_appointment2 = Appointment.create!(
  doctor: doctor3,
  patient: patient3,
  scheduled_start: 3.days.from_now.change(hour: 17, min: 0),
  scheduled_end: 3.days.from_now.change(hour: 17, min: 30),
  status: :confirmed,
  payment_status: :partial_paid,
  initial_fee_amount: doctor3.consultation_fee_initial,
  remaining_fee_amount: doctor3.consultation_fee_due,
  patient_notes: "Skin rash consultation"
)

puts "✓ Upcoming appointment 2 created"

# Pending payment appointment
pending_appointment = Appointment.create!(
  doctor: doctor1,
  patient: patient3,
  scheduled_start: 1.day.from_now.change(hour: 9, min: 30),
  scheduled_end: 1.day.from_now.change(hour: 10, min: 0),
  status: :pending_payment,
  payment_status: :unpaid,
  initial_fee_amount: doctor1.consultation_fee_initial,
  remaining_fee_amount: doctor1.consultation_fee_due,
  patient_notes: "General checkup"
)

puts "✓ Pending payment appointment created"

# Create Test Orders
puts "\nCreating test orders..."

test_order1 = past_appointment1.test_orders.create!(
  doctor: doctor1,
  patient: patient1,
  description: "ECG, Lipid Profile, Complete Blood Count",
  message_to_patient: "Please get these tests done at any accredited lab and upload the reports. Fasting required for lipid profile (8-10 hours)."
)

puts "✓ Test order 1 created"

test_order2 = past_appointment2.test_orders.create!(
  doctor: doctor2,
  patient: patient2,
  description: "Throat Culture, CBC",
  message_to_patient: "Please get throat culture test done to confirm bacterial infection."
)

puts "✓ Test order 2 created"

test_order3 = upcoming_appointment2.test_orders.create!(
  doctor: doctor3,
  patient: patient3,
  description: "Allergy Patch Test",
  message_to_patient: "Please schedule an allergy patch test at our dermatology lab."
)

puts "✓ Test order 3 created"

# Note: TestResultUpload requires file attachments which need to be added manually
puts "\n✓ Test orders created (test result uploads require file attachments)"

# Create Reviews
puts "\nCreating reviews..."

Review.create!(
  doctor: doctor1,
  patient: patient1,
  rating: 5,
  comment: "Excellent doctor! Very thorough examination and clear explanation. Highly recommended for heart related issues."
)

Review.create!(
  doctor: doctor2,
  patient: patient2,
  rating: 4,
  comment: "Good consultation. Doctor was professional and treatment was effective. Clinic could be cleaner."
)

Review.create!(
  doctor: doctor3,
  patient: patient3,
  rating: 5,
  comment: "Best dermatologist in Mumbai! Very knowledgeable and explained everything clearly."
)

puts "✓ Reviews created"

# Create Messages
puts "\nCreating messages..."

# Conversation between patient1 and doctor1
Message.create!(
  sender: patient1,
  receiver: doctor1,
  content: "Hello Doctor, I wanted to ask about the medication you prescribed. Should I take it before or after meals?",
  read_at: 6.days.ago
)

Message.create!(
  sender: doctor1,
  receiver: patient1,
  content: "Hello Amit, please take the aspirin after meals to avoid stomach irritation. Also drink plenty of water.",
  read_at: 6.days.ago
)

Message.create!(
  sender: patient1,
  receiver: doctor1,
  content: "Thank you Doctor! One more question - can I exercise normally or should I rest?",
  read_at: 5.days.ago
)

Message.create!(
  sender: doctor1,
  receiver: patient1,
  content: "Light walking is fine, but avoid strenuous exercise until your follow-up appointment. Listen to your body.",
  read_at: nil  # Unread
)

# Conversation between patient2 and doctor2
Message.create!(
  sender: patient2,
  receiver: doctor2,
  content: "Dr. Sharma, my throat is feeling much better now. Thank you for the treatment!",
  read_at: 3.days.ago
)

Message.create!(
  sender: doctor2,
  receiver: patient2,
  content: "That's great to hear! Complete the full course of antibiotics even though you're feeling better. Take care!",
  read_at: 3.days.ago
)

# Unread message from patient3
Message.create!(
  sender: patient3,
  receiver: doctor3,
  content: "Hi Doctor, the rash is spreading. Should I come in earlier for the appointment?",
  read_at: nil
)

puts "✓ Messages created"

# Create Notifications
puts "\nCreating notifications..."

Notification.create!(
  user: patient1,
  title: "Upcoming Appointment Reminder",
  body: "You have an appointment with Dr. #{doctor1.full_name} on #{upcoming_appointment1.scheduled_start.strftime('%b %d, %Y at %I:%M %p')}",
  metadata: { appointment_id: upcoming_appointment1.id, action: 'reminder' }
)

Notification.create!(
  user: doctor1,
  title: "Test Order Pending",
  body: "Patient #{patient1.full_name} has pending test order results to upload",
  metadata: { test_order_id: test_order1.id, action: 'pending_upload' },
  read_at: 6.days.ago
)

Notification.create!(
  user: patient2,
  title: "Appointment Confirmed",
  body: "Your appointment with Dr. #{doctor2.full_name} is confirmed for today at 4:00 PM",
  metadata: { appointment_id: today_appointment.id, action: 'confirmed' }
)

Notification.create!(
  user: doctor2,
  title: "New Review Received",
  body: "#{patient2.full_name} has left a review for your consultation",
  metadata: { review_id: Review.last.id, action: 'new_review' }
)

Notification.create!(
  user: patient3,
  title: "Test Order Created",
  body: "Dr. #{doctor3.full_name} has ordered tests for you. Please check the details.",
  metadata: { test_order_id: test_order3.id, action: 'new_test_order' }
)

Notification.create!(
  user: doctor3,
  title: "New Message",
  body: "You have a new message from #{patient3.full_name}",
  metadata: { message_id: Message.last.id, action: 'new_message' }
)

Notification.create!(
  user: patient3,
  title: "Appointment Pending Payment",
  body: "Your appointment with Dr. #{doctor1.full_name} is pending. Please complete the payment.",
  metadata: { appointment_id: pending_appointment.id, action: 'payment_pending' }
)

puts "✓ Notifications created"

# Create Audit Logs
puts "\nCreating audit logs..."

AuditLog.log(user: admin, action: 'verify_doctor', target: doctor1)
AuditLog.log(user: admin, action: 'verify_doctor', target: doctor2)
AuditLog.log(user: admin, action: 'verify_doctor', target: doctor3)
AuditLog.log(user: patient1, action: 'login')
AuditLog.log(user: doctor1, action: 'view_appointment', target: past_appointment1)
AuditLog.log(user: doctor1, action: 'complete_appointment', target: past_appointment1)
AuditLog.log(user: patient1, action: 'book_appointment', target: upcoming_appointment1)

puts "✓ Audit logs created"

# Summary
puts "\n" + "="*60
puts "SEED DATA SUMMARY"
puts "="*60
puts "\nLogin Credentials:"
puts "-"*60
puts "Admin:"
puts "  Phone: +919999999999"
puts "  Password: password123"
puts ""
puts "Doctor 1 (Cardiologist - Mumbai):"
puts "  Phone: +919876543210"
puts "  Password: doctor123"
puts "  Name: Dr. Rajesh Kumar"
puts ""
puts "Doctor 2 (ENT - Delhi):"
puts "  Phone: +919876543211"
puts "  Password: doctor123"
puts "  Name: Dr. Priya Sharma"
puts ""
puts "Doctor 3 (Dermatologist - Mumbai):"
puts "  Phone: +919876543212"
puts "  Password: doctor123"
puts "  Name: Dr. Anita Desai"
puts ""
puts "Patient 1 (Mumbai):"
puts "  Phone: +919123456789"
puts "  Password: patient123"
puts "  Name: Amit Patel"
puts ""
puts "Patient 2 (Delhi):"
puts "  Phone: +919123456788"
puts "  Password: patient123"
puts "  Name: Sneha Reddy"
puts ""
puts "Patient 3 (Mumbai):"
puts "  Phone: +919123456787"
puts "  Password: patient123"
puts "  Name: Rahul Verma"
puts ""
puts "-"*60
puts "Statistics:"
puts "  Total Users: #{User.count}"
puts "  Doctors: #{User.doctor.count} (#{User.where(role: :doctor, is_verified: true).count} verified)"
puts "  Patients: #{User.patient.count}"
puts "  Admins: #{User.admin.count}"
puts "  Appointment Slots: #{AppointmentSlot.count}"
puts "  Appointments: #{Appointment.count}"
puts "  Symptom Reports: #{SymptomReport.count}"
puts "  Test Orders: #{TestOrder.count}"
puts "  Reviews: #{Review.count}"
puts "  Messages: #{Message.count}"
puts "  Notifications: #{Notification.count}"
puts "  Awards: #{Award.count}"
puts "  Unavailable Dates: #{UnavailableDate.count}"
puts "  Audit Logs: #{AuditLog.count}"
puts "="*60
puts "\n✓ Seed data created successfully!"
puts "\nAll database tables now have seed data!"
